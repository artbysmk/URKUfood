import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../auth/schemas/user.schema';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { WhatsappService } from '../automation/whatsapp.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { Order, OrderDocument } from './schemas/order.schema';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly configService: ConfigService,
    private readonly whatsappService: WhatsappService,
  ) {}

  async create(dto: CreateOrderDto, authUser: JwtPayload) {
    const user = await this.userModel.findById(authUser.sub).lean();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const subtotal = dto.items.reduce(
      (sum, item) => sum + Number(item.price) * Number(item.quantity),
      0,
    );
    const needsProof = dto.paymentMethod === 'nequi' || dto.paymentMethod === 'bank_transfer';
    if (needsProof && !dto.paymentProofPath?.trim()) {
      throw new BadRequestException('Payment proof is required for Nequi or bank transfer');
    }

    const deliveryFee = dto.items.length > 0 ? 3.9 : 0;
    const serviceFee = dto.items.length > 0 ? 1.9 : 0;
    const smallOrderFee = subtotal >= 18 || dto.items.length == 0 ? 0 : 2.5;
    const discount = dto.promoCode?.trim().toUpperCase() === 'RAPPI15' ? 4.5 : 0;
    const total = subtotal + deliveryFee + serviceFee + smallOrderFee - discount;

    const order = await this.orderModel.create({
      userId: new Types.ObjectId(authUser.sub),
      userName: user.name,
      orderCode: `#${Date.now().toString().slice(-6)}`,
      items: dto.items.map((item) => ({
        ...item,
        restaurantId: item.restaurantId,
      })),
      restaurantNames: [...new Set(dto.items.map((item) => item.restaurantName))],
      deliveryAddress: dto.deliveryAddress,
      customerPhone: dto.customerPhone,
      deliveryInstructions: dto.deliveryInstructions ?? '',
      paymentMethod: dto.paymentMethod,
      paymentReference: dto.paymentReference ?? '',
      paymentProofPath: dto.paymentProofPath ?? '',
      status: 'confirmed',
      subtotal,
      deliveryFee,
      serviceFee,
      smallOrderFee,
      discount,
      total,
      itemCount: dto.items.reduce((sum, item) => sum + Number(item.quantity), 0),
      etaLabel: '25-35 min',
      automationLogs: [],
    });

    await this.sendOrderCreatedAutomation(order);
    return order;
  }

  findMine(authUser: JwtPayload) {
    return this.orderModel.find({ userId: new Types.ObjectId(authUser.sub) }).sort({ createdAt: -1 }).lean();
  }

  async updateStatus(id: string, dto: UpdateOrderStatusDto) {
    const order = await this.orderModel.findById(id);
    if (!order) {
      throw new NotFoundException('Order not found');
    }

    order.status = dto.status;
    await order.save();
    await this.sendOrderStatusAutomation(order);
    return order.toObject();
  }

  private async sendOrderCreatedAutomation(order: OrderDocument) {
    const itemsSummary = order.items
      .map((item) => {
        const lineTotal = (Number(item.price) * Number(item.quantity)).toFixed(2);
        return `  • ${item.quantity}x ${item.name} — $${Number(item.price).toFixed(2)} c/u → $${lineTotal}\n    _${item.restaurantName}_`;
      })
      .join('\n');
    const proofBase = this.configService.get<string>('PUBLIC_BASE_URL') ?? '';
    const proofLine = order.paymentProofPath
      ? `\nComprobante: ${proofBase}${order.paymentProofPath}`
      : '';
    const referenceLine = order.paymentReference
      ? `\nReferencia: ${order.paymentReference}`
      : '';

    const message = [
      `Hola, tu pedido ${order.orderCode} fue confirmado por ${this.configService.get<string>('WHATSAPP_FROM') ?? 'La Carta Bot'}.`,
      '',
      'Resumen del pedido:',
      itemsSummary,
      '',
      `Dirección: ${order.deliveryAddress}`,
      `Teléfono: ${order.customerPhone}`,
      `Método de pago: ${order.paymentMethod}`,
      `Indicaciones: ${order.deliveryInstructions || 'Sin indicaciones'}`,
      referenceLine,
      proofLine,
      '',
      `Total: ${order.total.toFixed(2)}`,
      `ETA estimada: ${order.etaLabel}`,
    ].filter((line) => line.length > 0).join('\n');

    const result = await this.whatsappService.sendTextMessage(order.customerPhone, message);
    order.automationLogs.push({
      type: 'order_created_whatsapp',
      target: order.customerPhone,
      delivered: Boolean(result.delivered),
      note: JSON.stringify(result),
    } as never);

    const notifyTo = this.configService.get<string>('WHATSAPP_NOTIFY_TO');
    if (notifyTo) {
      const adminBody = [
        `\uD83D\uDCE6 *Nuevo pedido ${order.orderCode}*`,
        '',
        `\uD83D\uDC64 *Cliente:* ${order.userName}`,
        `\uD83D\uDCDE *Teléfono:* ${order.customerPhone}`,
        `\uD83D\uDCCD *Dirección:* ${order.deliveryAddress}`,
        order.deliveryInstructions ? `\uD83D\uDCDD *Indicaciones:* ${order.deliveryInstructions}` : '',
        `\uD83D\uDCB3 *Pago:* ${order.paymentMethod}`,
        referenceLine,
        proofLine,
        '',
        `\uD83C\uDF7D *Detalle del pedido:*`,
        itemsSummary,
        '',
        `\uD83D\uDCB0 *Subtotal:* $${order.subtotal.toFixed(2)}`,
        order.deliveryFee > 0 ? `\uD83D\uDE9A *Envío:* $${order.deliveryFee.toFixed(2)}` : '',
        order.serviceFee > 0 ? `\u2699\uFE0F *Servicio:* $${order.serviceFee.toFixed(2)}` : '',
        order.discount > 0 ? `\uD83C\uDFF7\uFE0F *Descuento:* -$${order.discount.toFixed(2)}` : '',
        `\u2705 *TOTAL: $${order.total.toFixed(2)}*`,
      ].filter((line) => line.length > 0).join('\n');

      await this.whatsappService.sendOrderActionsToAdmin(
        notifyTo,
        adminBody,
        order.orderCode,
      );
    }

    await order.save();
  }

  private async sendOrderStatusAutomation(order: OrderDocument) {
    const label =
      order.status === 'confirmed'
        ? 'confirmado'
        : order.status === 'preparing'
          ? 'en preparación'
          : order.status === 'on_the_way'
            ? 'en camino'
            : 'entregado';

    const result = await this.whatsappService.sendTextMessage(
      order.customerPhone,
      `Actualización de tu pedido ${order.orderCode}: ahora está ${label}. Dirección: ${order.deliveryAddress}.`,
    );

    order.automationLogs.push({
      type: 'order_status_whatsapp',
      target: order.customerPhone,
      delivered: Boolean(result.delivered),
      note: JSON.stringify(result),
    } as never);
    await order.save();
  }
}
