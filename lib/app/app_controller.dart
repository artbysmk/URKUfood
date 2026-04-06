import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'app_data.dart';
import 'backend_bridge.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  final Random _random = Random();
  final BackendBridge _backendBridge = BackendBridge.instance;
  Timer? _ordersSyncTimer;
  bool _isSyncingOrders = false;

  bool isAuthenticated = false;
  bool isRegisterMode = false;
  bool isAuthBusy = false;
  bool rememberSession = true;
  String currentUserName = 'Invitado';
  String currentUserHandle = '@urku.foodie';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String? authErrorMessage;

  String searchQuery = '';
  String selectedHomeCategory = 'all';
  String selectedRestaurantFilter = 'all';
  String selectedMealWindow = 'current';
  int selectedTabIndex = 0;

  int points = 120;
  int triviaScore = 0;
  int currentTriviaIndex = 0;
  int? selectedTriviaOption;
  bool? lastTriviaAnswerCorrect;
  PaymentMethodType selectedPaymentMethod = PaymentMethodType.card;
  String deliveryAddress = 'Cra. 15 #22-33, Centro';
  String deliveryInstructions = 'Portería principal, timbrar una vez.';
  String promoCode = '';
  String paymentReference = '';
  Uint8List? paymentProofBytes;
  String? paymentProofLabel;

  final List<CartItem> cart = [];
  final List<OrderRecord> orderHistory = [];
  final Set<int> favoriteRestaurantIds = {2};
  final Set<String> likedRecommendedDishes = <String>{};
  final List<String> unlockedRewards = [];
  final List<Achievement> achievements = List<Achievement>.from(
    initialAchievements,
  );
  final List<RewardChallenge> challenges = List<RewardChallenge>.from(
    initialChallenges,
  );
  final List<AppNotification> notifications = [];
  final Map<int, List<ChatEntry>> chats = {};
  final List<SocialClip> _socialClips = List<SocialClip>.from(socialClips);
  final List<FoodPost> _foodPosts = List<FoodPost>.from(foodPosts);
  final Map<int, List<RestaurantComment>> _restaurantComments = {
    for (final restaurant in restaurants) restaurant.id: <RestaurantComment>[],
  };

  AppController() {
    rememberSession = _backendBridge.rememberSession;
    isAuthenticated = _backendBridge.hasSession;
    final cachedUser = _backendBridge.cachedUser;
    if (cachedUser != null && isAuthenticated) {
      _applyAuthenticatedUser(cachedUser);
    }
    for (final comment in initialRestaurantComments) {
      _restaurantComments
          .putIfAbsent(comment.restaurantId, () => [])
          .add(comment);
    }
  }

  Future<void> bootstrap() async {
    if (!_backendBridge.hasSession) {
      _resetAuthUser();
      return;
    }

    final cachedUser = _backendBridge.cachedUser;
    if (cachedUser != null) {
      _applyAuthenticatedUser(cachedUser);
    }

    try {
      final user = await _backendBridge.fetchCurrentUser();
      _applyAuthenticatedUser(user);
      await _syncOrders();
      _startOrdersSync();
    } catch (error) {
      if (_isUnauthorizedError(error)) {
        await _backendBridge.clearSession();
        _resetAuthUser();
        return;
      }

      if (cachedUser != null) {
        _applyAuthenticatedUser(cachedUser);
        _startOrdersSync();
      }
    }
  }

  @override
  void dispose() {
    _stopOrdersSync();
    super.dispose();
  }

  String get levelName {
    switch (levelNumber) {
      case 1:
        return 'Novato';
      case 2:
        return 'Explorador';
      case 3:
        return 'Gourmet';
      case 4:
        return 'Maestro';
      default:
        return 'Leyenda';
    }
  }

  int get levelNumber {
    final level = (points ~/ 200) + 1;
    return level.clamp(1, 5);
  }

  int get cartCount => cart.fold<int>(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      cart.fold<double>(0, (sum, item) => sum + item.price * item.quantity);

  TriviaQuestion get currentTriviaQuestion =>
      triviaQuestions[currentTriviaIndex];

  DeliveryMapSnapshot get activeMapSnapshot => liveMapSnapshot;

  List<FoodCategory> get availableCategories => foodCategories;

  List<Restaurant> get hotRestaurants =>
      restaurants.where((restaurant) => restaurant.isHot).toList();

  List<Restaurant> get recommendedRestaurants {
    final sorted = List<Restaurant>.from(restaurants)
      ..sort((left, right) {
        final hotCompare = (right.isHot ? 1 : 0).compareTo(left.isHot ? 1 : 0);
        if (hotCompare != 0) {
          return hotCompare;
        }
        final ratingCompare = right.rating.compareTo(left.rating);
        if (ratingCompare != 0) {
          return ratingCompare;
        }
        return _deliveryMinutes(left.deliveryTime).compareTo(
          _deliveryMinutes(right.deliveryTime),
        );
      });
    return sorted.take(8).toList();
  }

  List<RecommendedDish> get homeDishFeed =>
      filteredRecommendedDishes.take(10).toList();

  List<FoodPost> get homeSocialFeed => filteredFoodPosts.take(3).toList();

  List<Restaurant> get fastestRestaurants {
    final sorted = List<Restaurant>.from(restaurants)
      ..sort((left, right) => left.deliveryTime.compareTo(right.deliveryTime));
    return sorted.take(3).toList();
  }

  List<Restaurant> get affordableRestaurants {
    final sorted = List<Restaurant>.from(restaurants)
      ..sort((left, right) {
        final byPrice = _priceWeight(
          left.priceRange,
        ).compareTo(_priceWeight(right.priceRange));
        if (byPrice != 0) {
          return byPrice;
        }
        return right.rating.compareTo(left.rating);
      });
    return sorted.take(3).toList();
  }

  List<Restaurant> get bestSellingRestaurants {
    final sorted = List<Restaurant>.from(restaurants)
      ..sort((left, right) {
        final hotCompare = (right.isHot ? 1 : 0).compareTo(left.isHot ? 1 : 0);
        if (hotCompare != 0) {
          return hotCompare;
        }
        return right.rating.compareTo(left.rating);
      });
    return sorted.take(4).toList();
  }

  MealWindow get resolvedMealWindow {
    if (selectedMealWindow != 'current') {
      return mealWindows.firstWhere(
        (window) => window.id == selectedMealWindow,
        orElse: () => mealWindows.first,
      );
    }
    final hour = DateTime.now().hour;
    return mealWindows.firstWhere(
      (window) => hour >= window.startHour && hour <= window.endHour,
      orElse: () => mealWindows.last,
    );
  }

  List<Restaurant> get mealWindowRestaurants {
    final ids = resolvedMealWindow.restaurantIds;
    return restaurants
        .where((restaurant) => ids.contains(restaurant.id))
        .toList()
      ..sort(
        (left, right) => ids.indexOf(left.id).compareTo(ids.indexOf(right.id)),
      );
  }

  List<SocialClip> get filteredSocialClips {
    if (selectedHomeCategory == 'all') {
      return List<SocialClip>.from(_socialClips);
    }
    return _socialClips.where((clip) {
      final restaurant = restaurantById(clip.restaurantId);
      return restaurant?.cuisine == selectedHomeCategory ||
          (restaurant?.tags.contains(selectedHomeCategory) ?? false);
    }).toList();
  }

  List<FoodPost> get filteredFoodPosts {
    final query = searchQuery.trim().toLowerCase();
    return _foodPosts.where((post) {
      final restaurant = restaurantById(post.restaurantId);
      final matchesCategory =
          selectedHomeCategory == 'all' ||
          restaurant?.cuisine == selectedHomeCategory ||
          (restaurant?.tags.contains(selectedHomeCategory) ?? false);
      if (!matchesCategory) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return post.caption.toLowerCase().contains(query) ||
          post.restaurantName.toLowerCase().contains(query) ||
          post.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  List<SocialClip> clipsForRestaurant(int restaurantId) {
    return _socialClips
        .where((clip) => clip.restaurantId == restaurantId)
        .toList();
  }

  List<FoodPost> postsForRestaurant(int restaurantId) {
    return _foodPosts
        .where((post) => post.restaurantId == restaurantId)
        .toList();
  }

  List<RestaurantComment> commentsForRestaurant(int restaurantId) {
    return List<RestaurantComment>.from(
      _restaurantComments[restaurantId] ?? const <RestaurantComment>[],
    );
  }

  int get createdPostsCount =>
      _foodPosts.where((post) => post.author == currentUserName).length;

  int get createdClipsCount =>
      _socialClips.where((clip) => clip.author == currentUserName).length;

  double get deliveryFee => cart.isEmpty ? 0 : 3.90;

  double get serviceFee => cart.isEmpty ? 0 : 1.90;

  double get smallOrderFee => cartTotal >= 18 || cart.isEmpty ? 0 : 2.50;

  double get promoDiscount =>
      promoCode.trim().toUpperCase() == 'RAPPI15' ? 4.50 : 0;

  double get payableTotal =>
      cartTotal + deliveryFee + serviceFee + smallOrderFee - promoDiscount;

  bool get cartHasMultipleRestaurants =>
      cart.map((item) => item.restaurantId).toSet().length > 1;

  int get cartRestaurantCount =>
      cart.map((item) => item.restaurantId).toSet().length;

  List<OrderRecord> get activeOrders =>
      orderHistory.where((order) => order.status != OrderStatus.delivered).toList();

  List<Restaurant> get filteredRestaurants {
    final query = searchQuery.trim().toLowerCase();
    return restaurants.where((restaurant) {
      final matchesFilter = switch (selectedRestaurantFilter) {
        'all' => true,
        r'$' => restaurant.priceRange == r'$',
        r'$$' => restaurant.priceRange == r'$$',
        'near' => restaurant.id <= 2,
        _ => true,
      };

      if (!matchesFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.description.toLowerCase().contains(query) ||
          restaurant.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  List<Restaurant> get featuredRestaurants {
    final ids = featuredRestaurantIds.toSet();
    return restaurants.where((restaurant) {
      final matchesFeatured = ids.contains(restaurant.id);
      if (!matchesFeatured) {
        return false;
      }
      if (searchQuery.trim().isEmpty) {
        return true;
      }
      final query = searchQuery.trim().toLowerCase();
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.description.toLowerCase().contains(query);
    }).toList()..sort(
      (left, right) => featuredRestaurantIds
          .indexOf(left.id)
          .compareTo(featuredRestaurantIds.indexOf(right.id)),
    );
  }

  List<PromoCampaign> get filteredPromotions {
    if (selectedHomeCategory == 'all') {
      return promotions;
    }
    return promotions.where((promo) {
      final restaurant = restaurantById(promo.restaurantId);
      return restaurant?.cuisine == selectedHomeCategory ||
          (restaurant?.tags.contains(selectedHomeCategory) ?? false);
    }).toList();
  }

  void toggleAuthMode() {
    isRegisterMode = !isRegisterMode;
    authErrorMessage = null;
    notifyListeners();
  }

  Future<void> setRememberSession(bool value) async {
    rememberSession = value;
    await _backendBridge.setRememberSession(value);
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    debugPrint('[Auth] signIn tapped for $trimmedEmail');
    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      authErrorMessage = 'Ingresa correo y contraseña.';
      notifyListeners();
      return;
    }

    try {
      isAuthBusy = true;
      authErrorMessage = null;
      notifyListeners();
      final response = await _backendBridge.login(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      _applyAuthenticatedUser(response['user'] as Map<String, dynamic>);
      await _syncOrders();
      _startOrdersSync();
      debugPrint('[Auth] signIn success for $trimmedEmail');
      isRegisterMode = false;
      _pushNotification('Sesión iniciada como $currentUserName');
    } catch (error) {
      debugPrint('[Auth] signIn failed for $trimmedEmail: $error');
      _resetAuthUser();
      authErrorMessage = _readableError(error);
    } finally {
      isAuthBusy = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedPhone = _normalizePhone(phone);
    debugPrint('[Auth] register tapped for $trimmedEmail');
    if (trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPassword.isEmpty || trimmedPhone.isEmpty) {
      authErrorMessage = 'Completa todos los campos para crear la cuenta.';
      notifyListeners();
      return;
    }

    try {
      isAuthBusy = true;
      authErrorMessage = null;
      notifyListeners();
      final response = await _backendBridge.register(
        name: trimmedName,
        email: trimmedEmail,
        password: trimmedPassword,
        phone: trimmedPhone,
      );
      _applyAuthenticatedUser(response['user'] as Map<String, dynamic>);
      await _syncOrders();
      _startOrdersSync();
      debugPrint('[Auth] register success for $trimmedEmail');
      isRegisterMode = false;
      _pushNotification('Cuenta creada para $currentUserName');
    } catch (error) {
      debugPrint('[Auth] register failed for $trimmedEmail: $error');
      _resetAuthUser();
      authErrorMessage = _readableError(error);
    } finally {
      isAuthBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _backendBridge.clearSession();
    _resetAuthUser();
    _stopOrdersSync();
    isRegisterMode = false;
    selectedTabIndex = 0;
    orderHistory.clear();
    notifyListeners();
  }

  List<RecommendedDish> get filteredRecommendedDishes {
    final query = searchQuery.trim().toLowerCase();
    return recommendedDishes.where((dish) {
      final restaurant = restaurantById(dish.restaurantId);
      final matchesCategory =
          selectedHomeCategory == 'all' ||
          restaurant?.cuisine == selectedHomeCategory ||
          (restaurant?.tags.contains(selectedHomeCategory) ?? false);

      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return dish.dishName.toLowerCase().contains(query) ||
          dish.restaurantName.toLowerCase().contains(query) ||
          dish.description.toLowerCase().contains(query);
    }).toList();
  }

  Restaurant? restaurantById(int id) {
    for (final restaurant in restaurants) {
      if (restaurant.id == id) {
        return restaurant;
      }
    }
    return null;
  }

  List<MenuItemModel> menuForRestaurant(int restaurantId) {
    return List<MenuItemModel>.from(
      menuItemsByRestaurant[restaurantId] ?? const <MenuItemModel>[],
    );
  }

  List<ChatEntry> chatForRestaurant(int restaurantId, String restaurantName) {
    return chats.putIfAbsent(
      restaurantId,
      () => <ChatEntry>[
        ChatEntry(
          message:
              'Hola, soy el asistente de $restaurantName. ¿Qué deseas pedir o consultar?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  void setTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setHomeCategory(String category) {
    selectedHomeCategory = category;
    notifyListeners();
  }

  void setRestaurantFilter(String filter) {
    selectedRestaurantFilter = filter;
    notifyListeners();
  }

  void setMealWindow(String id) {
    selectedMealWindow = id;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethodType type) {
    selectedPaymentMethod = type;
    notifyListeners();
  }

  void updateDeliveryAddress(String value) {
    deliveryAddress = value;
    notifyListeners();
  }

  void updateDeliveryInstructions(String value) {
    deliveryInstructions = value;
    notifyListeners();
  }

  void updateCustomerPhone(String value) {
    currentUserPhone = _normalizePhone(value);
    notifyListeners();
  }

  Future<void> updateProfileBasics({
    required String name,
    required String phone,
    required String address,
    required String deliveryNotes,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      currentUserName = trimmedName;
      currentUserHandle = '@${_slugifyHandle(trimmedName)}';
    }
    currentUserPhone = _normalizePhone(phone);
    deliveryAddress = address.trim();
    deliveryInstructions = deliveryNotes.trim();

    if (_backendBridge.hasSession) {
      await _backendBridge.updateCachedUser({
        'email': currentUserEmail,
        'name': currentUserName,
        'handle': currentUserHandle.replaceFirst('@', ''),
        'phone': currentUserPhone,
      });
    }

    notifyListeners();
  }

  void updatePromoCode(String value) {
    promoCode = value;
    notifyListeners();
  }

  void updatePaymentReference(String value) {
    paymentReference = value;
    notifyListeners();
  }

  void setPaymentProof({Uint8List? bytes, String? label}) {
    paymentProofBytes = bytes;
    paymentProofLabel = label;
    notifyListeners();
  }

  void toggleFavoriteRestaurant(int restaurantId) {
    if (favoriteRestaurantIds.contains(restaurantId)) {
      favoriteRestaurantIds.remove(restaurantId);
      _pushNotification('Restaurante eliminado de favoritos');
    } else {
      favoriteRestaurantIds.add(restaurantId);
      _pushNotification('Restaurante guardado en favoritos');
    }
    notifyListeners();
  }

  void likeRecommendedDish(RecommendedDish dish) {
    if (!likedRecommendedDishes.add(dish.dishName)) {
      return;
    }
    favoriteRestaurantIds.add(dish.restaurantId);
    addPoints(5, 'Me gusta en plato recomendado');
    _pushNotification(
      'Te gustó ${dish.dishName}. Se guardó su restaurante en favoritos.',
    );
    notifyListeners();
  }

  void addMenuItem(MenuItemModel item, Restaurant restaurant) {
    _addToCart(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      name: item.name,
      price: item.price,
    );
    addPoints(2, 'Agregar al carrito');
    _pushNotification('${item.name} agregado al carrito');
  }

  void addRecommendedDish(RecommendedDish dish) {
    _addToCart(
      restaurantId: dish.restaurantId,
      restaurantName: dish.restaurantName,
      name: dish.dishName,
      price: dish.price,
    );
    addPoints(2, 'Agregar plato recomendado');
    _pushNotification('${dish.dishName} agregado al carrito');
  }

  void _addToCart({
    required int restaurantId,
    required String restaurantName,
    required String name,
    required double price,
  }) {
    final index = cart.indexWhere(
      (item) => item.name == name && item.restaurantId == restaurantId,
    );
    if (index >= 0) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(
        CartItem(
          id: '${restaurantId}_${name}_${DateTime.now().microsecondsSinceEpoch}',
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          name: name,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void increaseCartItem(String id) {
    final index = cart.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    notifyListeners();
  }

  void decreaseCartItem(String id) {
    final index = cart.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    final item = cart[index];
    if (item.quantity <= 1) {
      cart.removeAt(index);
    } else {
      cart[index] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  void removeCartItem(String id) {
    cart.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    if (cart.isEmpty) {
      return;
    }
    cart.clear();
    promoCode = '';
    paymentReference = '';
    paymentProofBytes = null;
    paymentProofLabel = null;
    _pushNotification('Carrito vaciado');
    notifyListeners();
  }

  Future<bool> confirmOrder() async {
    if (cart.isEmpty) {
      _pushNotification('Agrega items al carrito antes de confirmar.');
      notifyListeners();
      return false;
    }

    if (deliveryAddress.trim().isEmpty) {
      _pushNotification('Agrega una dirección de entrega válida.');
      notifyListeners();
      return false;
    }

    if (currentUserPhone.trim().isEmpty) {
      _pushNotification('Agrega tu número de teléfono antes de pagar.');
      notifyListeners();
      return false;
    }

    if ((selectedPaymentMethod == PaymentMethodType.nequi ||
            selectedPaymentMethod == PaymentMethodType.bankTransfer) &&
        paymentProofBytes == null) {
      _pushNotification('Debes adjuntar un comprobante para este método de pago.');
      notifyListeners();
      return false;
    }

    final snapshot = cart.map((item) => item.copyWith()).toList();
    final orderId = 'order-${DateTime.now().microsecondsSinceEpoch}';
    final restaurantNames = snapshot
        .map((item) => item.restaurantName)
        .toSet()
        .toList();
    final submittedPromoCode = promoCode;
    final submittedPaymentReference = paymentReference;
    final submittedPaymentProofBytes = paymentProofBytes;
    final submittedPaymentProofLabel = paymentProofLabel;
    final submittedDeliveryAddress = deliveryAddress;
    final submittedDeliveryInstructions = deliveryInstructions;
    final submittedPhone = currentUserPhone;

    final currentQuantity = cartCount;
    addPoints(payableTotal.floor(), 'Pedido realizado');
    cart.clear();
    promoCode = '';
    paymentReference = '';
    paymentProofBytes = null;
    paymentProofLabel = null;
    _unlockAchievement('Primer pedido');
    if (currentQuantity >= 2) {
      completeChallenge('two-items');
    }

    if (_backendBridge.hasSession) {
      try {
        String? proofPath;
        if (submittedPaymentProofBytes != null && submittedPaymentProofLabel != null) {
          proofPath = await _backendBridge.uploadPaymentProof(
            bytes: submittedPaymentProofBytes,
            filename: submittedPaymentProofLabel,
          );
        }

        await _backendBridge.createOrder({
          'items': snapshot
              .map(
                (item) => {
                  'restaurantId': item.restaurantId.toString(),
                  'restaurantName': item.restaurantName,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                },
              )
              .toList(),
          'deliveryAddress': deliveryAddress,
          'deliveryInstructions': submittedDeliveryInstructions,
          'customerPhone': submittedPhone,
          'paymentMethod': _paymentMethodBackendKey(selectedPaymentMethod),
          'promoCode': submittedPromoCode,
          'paymentReference': submittedPaymentReference,
          'paymentProofPath': proofPath,
        });
        await _syncOrders();
        _startOrdersSync();
        _pushNotification('Pedido confirmado con éxito');
        notifyListeners();
      } catch (_) {
        orderHistory.insert(
          0,
          OrderRecord(
            id: orderId,
            orderCode: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            createdAt: DateTime.now(),
            items: snapshot,
            restaurantNames: restaurantNames,
            itemCount: snapshot.fold<int>(0, (sum, item) => sum + item.quantity),
            status: OrderStatus.confirmed,
            paymentMethod: selectedPaymentMethod,
            customerPhone: submittedPhone,
            deliveryAddress: submittedDeliveryAddress,
            deliveryInstructions: submittedDeliveryInstructions,
            paymentReference: submittedPaymentReference,
            paymentProofLabel: submittedPaymentProofLabel,
            subtotal: cartTotal,
            deliveryFee: deliveryFee,
            serviceFee: serviceFee,
            smallOrderFee: smallOrderFee,
            discount: promoDiscount,
            etaLabel: activeMapSnapshot.eta,
            total: payableTotal,
          ),
        );
        _pushNotification('Pedido guardado localmente; no se pudo sincronizar con el backend.');
        notifyListeners();
      }
    } else {
      orderHistory.insert(
        0,
        OrderRecord(
          id: orderId,
          orderCode: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          createdAt: DateTime.now(),
          items: snapshot,
          restaurantNames: restaurantNames,
          itemCount: snapshot.fold<int>(0, (sum, item) => sum + item.quantity),
          status: OrderStatus.confirmed,
          paymentMethod: selectedPaymentMethod,
          customerPhone: submittedPhone,
          deliveryAddress: submittedDeliveryAddress,
          deliveryInstructions: submittedDeliveryInstructions,
          paymentReference: submittedPaymentReference,
          paymentProofLabel: submittedPaymentProofLabel,
          subtotal: cartTotal,
          deliveryFee: deliveryFee,
          serviceFee: serviceFee,
          smallOrderFee: smallOrderFee,
          discount: promoDiscount,
          etaLabel: activeMapSnapshot.eta,
          total: payableTotal,
        ),
      );
      _pushNotification('Pedido confirmado con éxito');
      notifyListeners();
    }

    return true;
  }

  Future<void> refreshOrders() async {
    await _syncOrders();
  }

  void reorderOrder(OrderRecord order) {
    cart
      ..clear()
      ..addAll(
        order.items.map(
          (item) => CartItem(
            id: '${item.restaurantId}_${item.name}_${DateTime.now().microsecondsSinceEpoch}_${item.quantity}',
            restaurantId: item.restaurantId,
            restaurantName: item.restaurantName,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
          ),
        ),
      );
    promoCode = '';
    _pushNotification('Se cargó nuevamente ${order.orderCode} en el carrito');
    notifyListeners();
  }

  void addPoints(int amount, String reason) {
    points += amount;
    if (points >= 500) {
      _unlockAchievement('Foodie nivel 2');
    }
    _pushNotification('+$amount pts por $reason');
    notifyListeners();
  }

  String spinWheel() {
    final reward = wheelRewards[_random.nextInt(wheelRewards.length)];
    if (reward.contains('pts')) {
      final parsedPoints =
          int.tryParse(reward.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (parsedPoints > 0) {
        points += parsedPoints;
      }
    }
    if (!unlockedRewards.contains(reward)) {
      unlockedRewards.add(reward);
    }
    _unlockAchievement('Ruleta ganador');
    _pushNotification('Ruleta: $reward');
    notifyListeners();
    return reward;
  }

  void completeChallenge(String challengeId) {
    final index = challenges.indexWhere(
      (challenge) => challenge.id == challengeId,
    );
    if (index < 0 || challenges[index].completed) {
      return;
    }

    final challenge = challenges[index];
    challenges[index] = challenge.copyWith(completed: true);
    points += challenge.points;
    _pushNotification('${challenge.title}: +${challenge.points} pts');
    notifyListeners();
  }

  void answerTrivia(int optionIndex) {
    if (selectedTriviaOption != null) {
      return;
    }

    selectedTriviaOption = optionIndex;
    final isCorrect = optionIndex == currentTriviaQuestion.correctIndex;
    lastTriviaAnswerCorrect = isCorrect;

    if (isCorrect) {
      triviaScore += 25;
      points += 25;
      _pushNotification('Respuesta correcta. +25 pts');
    } else {
      triviaScore += 5;
      points += 5;
      _pushNotification('Respuesta incorrecta. +5 pts por participar');
    }

    completeChallenge('trivia');
    if (triviaScore >= 100) {
      _unlockAchievement('Trivia master');
    }
    notifyListeners();
  }

  void nextTriviaQuestion() {
    currentTriviaIndex = _random.nextInt(triviaQuestions.length);
    selectedTriviaOption = null;
    lastTriviaAnswerCorrect = null;
    notifyListeners();
  }

  void markMenuExplored() {
    completeChallenge('menu');
    _unlockAchievement('Explorador de menús');
  }

  Future<void> sendChatMessage({
    required int restaurantId,
    required String restaurantName,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final chat = chatForRestaurant(restaurantId, restaurantName);
    chat.add(
      ChatEntry(message: trimmed, isUser: true, timestamp: DateTime.now()),
    );
    completeChallenge('chat');
    notifyListeners();

    if (_backendBridge.hasSession) {
      try {
        final response = await _backendBridge.sendChatMessage(
          restaurantId: restaurantId.toString(),
          restaurantName: restaurantName,
          message: trimmed,
        );
        for (final entry in response.skip(1)) {
          final mapped = entry as Map<String, dynamic>;
          chat.add(
            ChatEntry(
              message: mapped['message'] as String? ?? '',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
        notifyListeners();
        return;
      } catch (_) {}
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));

    chat.add(
      ChatEntry(
        message:
            '$restaurantName: gracias por escribir. Tenemos disponibilidad y podemos ayudarte con tu pedido.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    addPoints(5, 'Chat interactivo');
    notifyListeners();
  }

  void addCustomization(String customization) {
    _pushNotification('Personalización añadida: $customization');
    addPoints(1, 'Explorar personalización');
  }

  void createFoodPost({
    required int restaurantId,
    required String caption,
    Uint8List? mediaBytes,
    String? mediaLabel,
  }) {
    final restaurant = restaurantById(restaurantId);
    final trimmed = caption.trim();
    if (restaurant == null || trimmed.isEmpty) {
      return;
    }

    _foodPosts.insert(
      0,
      FoodPost(
        id: 'post-${DateTime.now().microsecondsSinceEpoch}',
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        author: currentUserName,
        authorRole: 'Food creator',
        imageAsset: restaurant.bannerAssets.first,
        caption: trimmed,
        likesLabel: '0',
        commentsLabel: '${commentsForRestaurant(restaurantId).length}',
        tags: restaurant.tags.take(3).toList(),
        mediaBytes: mediaBytes,
        mediaLabel: mediaLabel,
      ),
    );
    addPoints(12, 'Crear post');
    _pushNotification('Publicaste un post en ${restaurant.name}');
    notifyListeners();
  }

  void createSocialClip({
    required int restaurantId,
    required String title,
    int durationSeconds = 30,
    Uint8List? mediaBytes,
    String? mediaLabel,
  }) {
    final restaurant = restaurantById(restaurantId);
    final trimmed = title.trim();
    if (restaurant == null || trimmed.isEmpty) {
      return;
    }

    _socialClips.insert(
      0,
      SocialClip(
        id: 'clip-${DateTime.now().microsecondsSinceEpoch}',
        restaurantId: restaurant.id,
        title: trimmed,
        author: currentUserName,
        coverImage: restaurant.bannerAssets.first,
        durationLabel: durationSeconds == 60 ? '1:00' : '0:30',
        viewsLabel: 'Nuevo',
        durationSeconds: durationSeconds,
        mediaBytes: mediaBytes,
        mediaLabel: mediaLabel,
      ),
    );
    addPoints(15, 'Crear reel');
    _pushNotification('Publicaste un reel en ${restaurant.name}');
    notifyListeners();
  }

  void addRestaurantComment({
    required int restaurantId,
    required String message,
  }) {
    final restaurant = restaurantById(restaurantId);
    final trimmed = message.trim();
    if (restaurant == null || trimmed.isEmpty) {
      return;
    }

    _restaurantComments
        .putIfAbsent(restaurantId, () => [])
        .insert(
          0,
          RestaurantComment(
            id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
            restaurantId: restaurantId,
            author: currentUserName,
            handle: currentUserHandle,
            message: trimmed,
            timeLabel: 'Ahora',
            likesLabel: '0',
          ),
        );
    addPoints(4, 'Comentar restaurante');
    _pushNotification('Comentaste en ${restaurant.name}');
    notifyListeners();

    if (_backendBridge.hasSession) {
      unawaited(
        _backendBridge.createComment(
          restaurantId: restaurantId.toString(),
          message: trimmed,
        ),
      );
    }
  }

  void toggleCommentLike({
    required int restaurantId,
    required String commentId,
  }) {
    final comments = _restaurantComments[restaurantId];
    if (comments == null) {
      return;
    }

    final index = comments.indexWhere((comment) => comment.id == commentId);
    if (index < 0) {
      return;
    }

    final current = comments[index];
    final likes = int.tryParse(current.likesLabel) ?? 0;
    final liked = !current.likedByCurrentUser;
    final nextLikes = liked ? likes + 1 : (likes > 0 ? likes - 1 : 0);
    comments[index] = current.copyWith(
      likesLabel: '$nextLikes',
      likedByCurrentUser: liked,
    );
    notifyListeners();
  }

  void addSurpriseOrder() {
    final restaurant = restaurants[_random.nextInt(restaurants.length)];
    final menuItems =
        menuItemsByRestaurant[restaurant.id] ?? const <MenuItemModel>[];
    if (menuItems.isEmpty) {
      _pushNotification('No hay menú disponible para pedido sorpresa.');
      notifyListeners();
      return;
    }

    final item = menuItems.first;
    _addToCart(
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      name: '${item.name} sorpresa',
      price: item.price,
    );
    addPoints(15, 'Modo sorpresa');
    _pushNotification('Pedido sorpresa agregado: ${item.name}');
  }

  PaymentMethodOption paymentMethodDetails(PaymentMethodType type) {
    return paymentMethods.firstWhere(
      (method) => method.type == type,
      orElse: () => paymentMethods.first,
    );
  }

  void dismissNotification(String id) {
    notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void _unlockAchievement(String achievementName) {
    final index = achievements.indexWhere(
      (achievement) => achievement.name == achievementName,
    );
    if (index < 0 || achievements[index].unlocked) {
      return;
    }
    achievements[index] = achievements[index].copyWith(unlocked: true);
    _pushNotification('Logro desbloqueado: $achievementName');
  }

  void _pushNotification(String message) {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
    );
    notifications.add(notification);
    unawaited(
      Future<void>.delayed(const Duration(seconds: 3), () {
        notifications.removeWhere((item) => item.id == notification.id);
        notifyListeners();
      }),
    );
  }

  int _deliveryMinutes(String deliveryTime) {
    final match = RegExp(r'(\d+)').firstMatch(deliveryTime);
    return int.tryParse(match?.group(1) ?? '') ?? 99;
  }

  String _displayNameFromEmail(String email) {
    final left = email.split('@').first.trim();
    if (left.isEmpty) {
      return 'URKU Foodie';
    }
    return left
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _slugifyHandle(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
        .replaceAll(RegExp(r'^\.+|\.+$'), '');
  }

  int _priceWeight(String value) => value.length;

  String _paymentMethodBackendKey(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.cash:
        return 'cash';
      case PaymentMethodType.wallet:
        return 'wallet';
      case PaymentMethodType.instant:
        return 'instant';
      case PaymentMethodType.nequi:
        return 'nequi';
      case PaymentMethodType.bankTransfer:
        return 'bank_transfer';
    }
  }

  void _applyAuthenticatedUser(Map<String, dynamic> user) {
    currentUserEmail = user['email'] as String? ?? '';
    currentUserName =
        user['name'] as String? ?? _displayNameFromEmail(currentUserEmail);
    currentUserHandle =
        '@${(user['handle'] as String? ?? _slugifyHandle(currentUserName)).replaceFirst('@', '')}';
    currentUserPhone = user['phone'] as String? ?? '';
    isAuthenticated = true;
    authErrorMessage = null;
  }

  void _resetAuthUser() {
    isAuthenticated = false;
    currentUserName = 'Invitado';
    currentUserHandle = '@urku.foodie';
    currentUserEmail = '';
    currentUserPhone = '';
    _stopOrdersSync();
  }

  void _startOrdersSync() {
    _stopOrdersSync();
    if (!_backendBridge.hasSession) {
      return;
    }

    _ordersSyncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(_syncOrders(silent: true));
    });
  }

  void _stopOrdersSync() {
    _ordersSyncTimer?.cancel();
    _ordersSyncTimer = null;
  }

  Future<void> _syncOrders({bool silent = false}) async {
    if (!_backendBridge.hasSession || _isSyncingOrders) {
      return;
    }

    _isSyncingOrders = true;
    try {
      final rawOrders = await _backendBridge.fetchMyOrders();
      orderHistory
        ..clear()
        ..addAll(
          rawOrders
              .whereType<Map<String, dynamic>>()
              .map(_orderFromBackend)
              .toList(),
        );
      if (!silent) {
        notifyListeners();
      } else {
        notifyListeners();
      }
    } catch (error) {
      if (_isUnauthorizedError(error)) {
        await _backendBridge.clearSession();
        _resetAuthUser();
        notifyListeners();
      }
    } finally {
      _isSyncingOrders = false;
    }
  }

  OrderRecord _orderFromBackend(Map<String, dynamic> raw) {
    final items = (raw['items'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CartItem(
            id:
                '${item['restaurantId']}_${item['name']}_${item['quantity']}_${raw['_id'] ?? raw['orderCode']}',
            restaurantId: int.tryParse('${item['restaurantId']}') ?? 0,
            restaurantName: item['restaurantName'] as String? ?? '',
            name: item['name'] as String? ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0,
            quantity: (item['quantity'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    return OrderRecord(
      id: raw['_id'] as String? ?? raw['orderCode'] as String? ?? '',
      orderCode: raw['orderCode'] as String? ?? '',
      createdAt: DateTime.tryParse(raw['createdAt'] as String? ?? '') ?? DateTime.now(),
      items: items,
      restaurantNames: (raw['restaurantNames'] as List<dynamic>? ?? <dynamic>[])
          .map((entry) => entry.toString())
          .toList(),
      itemCount: (raw['itemCount'] as num?)?.toInt() ?? items.fold<int>(0, (sum, item) => sum + item.quantity),
      status: _orderStatusFromBackend(raw['status'] as String?),
      paymentMethod: _paymentMethodFromBackend(raw['paymentMethod'] as String?),
      customerPhone: raw['customerPhone'] as String? ?? '',
      deliveryAddress: raw['deliveryAddress'] as String? ?? '',
      deliveryInstructions: raw['deliveryInstructions'] as String? ?? '',
      paymentReference: raw['paymentReference'] as String? ?? '',
      paymentProofLabel: raw['paymentProofPath'] as String?,
      subtotal: (raw['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (raw['deliveryFee'] as num?)?.toDouble() ?? 0,
      serviceFee: (raw['serviceFee'] as num?)?.toDouble() ?? 0,
      smallOrderFee: (raw['smallOrderFee'] as num?)?.toDouble() ?? 0,
      discount: (raw['discount'] as num?)?.toDouble() ?? 0,
      etaLabel: raw['etaLabel'] as String? ?? '25-35 min',
      total: (raw['total'] as num?)?.toDouble() ?? 0,
    );
  }

  OrderStatus _orderStatusFromBackend(String? status) {
    switch (status) {
      case 'preparing':
        return OrderStatus.preparing;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'confirmed':
      default:
        return OrderStatus.confirmed;
    }
  }

  PaymentMethodType _paymentMethodFromBackend(String? value) {
    switch (value) {
      case 'cash':
        return PaymentMethodType.cash;
      case 'wallet':
        return PaymentMethodType.wallet;
      case 'instant':
        return PaymentMethodType.instant;
      case 'nequi':
        return PaymentMethodType.nequi;
      case 'bank_transfer':
        return PaymentMethodType.bankTransfer;
      case 'card':
      default:
        return PaymentMethodType.card;
    }
  }

  bool _isUnauthorizedError(Object error) {
    return error is BackendBridgeException &&
        (error.statusCode == 401 || error.statusCode == 403);
  }

  String _normalizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return '';
    }

    return hasPlus ? '+$digits' : digits;
  }

  String _readableError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return 'No se pudo completar la autenticación.';
    }
    return raw;
  }
}
