import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AvailabilityService } from './availability.service';
import { StartAvailabilityDto } from './dto/start-availability.dto';

@ApiTags('automation-availability')
@Controller('automation/availability')
export class AvailabilityController {
  constructor(private readonly availabilityService: AvailabilityService) {}

  @Post('sessions')
  startSession(@Body() dto: StartAvailabilityDto) {
    return this.availabilityService.startSession(dto);
  }

  @Get('sessions/:id')
  getSession(@Param('id') id: string) {
    return this.availabilityService.getSession(id);
  }

  @Post('sessions/:id/restaurants/:restaurantId/continue')
  continueWithIngredientIssue(
    @Param('id') id: string,
    @Param('restaurantId') restaurantId: string,
  ) {
    return this.availabilityService.continueWithIngredientIssue(id, restaurantId);
  }

  @Post('sessions/:id/cancel')
  cancelSession(@Param('id') id: string) {
    return this.availabilityService.cancelSession(id);
  }
}