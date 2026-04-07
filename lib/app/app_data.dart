import 'models.dart';

const homeCategories = <String>[
  'all',
  'fast',
  'italian',
  'local',
  'healthy',
  'seafood',
  'street',
  'premium',
];

const homeCategoryLabels = <String, String>{
  'all': 'Todos',
  'fast': 'Comidas rapidas',
  'italian': 'Pizza y pasta',
  'local': 'Comida local',
  'healthy': 'Saludable',
  'seafood': 'Mariscos',
  'street': 'Street food',
  'premium': 'Premium',
};

const foodCategories = <FoodCategory>[
  FoodCategory(id: 'all', label: 'Todo', icon: '🍽️', cuisines: ['all']),
  FoodCategory(id: 'fast', label: 'Rápidas', icon: '🍔', cuisines: ['fast']),
  FoodCategory(
    id: 'italian',
    label: 'Italiana',
    icon: '🍕',
    cuisines: ['italian'],
  ),
  FoodCategory(id: 'local', label: 'Local', icon: '🍲', cuisines: ['local']),
  FoodCategory(
    id: 'healthy',
    label: 'Healthy',
    icon: '🥗',
    cuisines: ['healthy'],
  ),
  FoodCategory(
    id: 'seafood',
    label: 'Mar',
    icon: '🦐',
    cuisines: ['italian', 'local'],
  ),
  FoodCategory(
    id: 'street',
    label: 'Street',
    icon: '🌮',
    cuisines: ['fast', 'local'],
  ),
  FoodCategory(id: 'premium', label: 'Chef', icon: '🔥', cuisines: ['local']),
];

const restaurantFilters = <String>[
  'all',
  'fast_food',
  'pizza_pasta',
  'desserts',
  'international',
  'traditional',
];

const restaurantFilterLabels = <String, String>{
  'all': 'Todos',
  'fast_food': 'Comidas Rápidas',
  'pizza_pasta': 'Pizza & Pasta',
  'desserts': 'Postres y Helados',
  'international': 'Internacional',
  'traditional': 'Tradicionales',
};

const restaurants = <Restaurant>[
  Restaurant(
    id: 1,
    name: 'Restaurante El Tambello',
    cuisine: 'italian',
    priceRange: r'$$',
    rating: 4.8,
    deliveryTime: '20-30 min',
    logoAsset: 'images/el_tambeno/el_tambeno_logo.png',
    bannerAssets: [
      'images/el_tambeno/tambeno_banner.jpg',
      'images/el_tambeno/tambeno_banner1.jpg',
      'images/el_tambeno/tambeno_banner2.jpg',
      'images/el_tambeno/tambeno_banner3.jpg',
      'images/el_tambeno/tambeno_banner4.jpg',
    ],
    contactName: 'Chef Mario Rossi',
    contactPhotoAsset: 'images/el_tambeno/tambeno_banner4.jpg',
    instagram: '@pizzafuego',
    facebook: 'PizzaFuegoOficial',
    phone: '+57 300 123 4567',
    address: 'Calle 123 #45-67, Centro',
    description:
        'Carta amplia con platos de mar, carnes y entradas para compartir en un ambiente cálido.',
    tags: ['italian', 'seafood', 'shareable'],
    mapX: 0.22,
    mapY: 0.36,
    latitude: 1.21361,
    longitude: -77.28111,
    isHot: true,
  ),
  Restaurant(
    id: 2,
    name: 'Burger Lab',
    cuisine: 'fast',
    priceRange: r'$',
    rating: 4.5,
    deliveryTime: '15-25 min',
    logoAsset: 'images/burguer_house/burguer_logo.png',
    bannerAssets: [
      'images/burguer_house/banner_burguer.jpg',
      'images/burguer_house/banner_burguer1.jpg',
      'images/burguer_house/banner_burguer2.jpg',
    ],
    contactName: 'Sofía Martínez',
    contactPhotoAsset: 'images/burguer_house/banner_burguer2.jpg',
    instagram: '@burgerlab',
    facebook: 'BurgerLabOficial',
    phone: '+57 301 987 6543',
    address: 'Av. Siempre Viva #742',
    description:
        'Hamburguesas con identidad propia, cocina directa y foco en ingredientes intensos.',
    tags: ['fast', 'burger', 'combo'],
    mapX: 0.58,
    mapY: 0.22,
    latitude: 1.22134,
    longitude: -77.28195,
    isHot: true,
  ),
  Restaurant(
    id: 3,
    name: 'Sazón Local',
    cuisine: 'local',
    priceRange: r'$$',
    rating: 4.9,
    deliveryTime: '25-35 min',
    logoAsset: 'images/resto_papas/logoapp1.png',
    bannerAssets: [
      'images/mi_restaurante/restaurante_banner1.jpg',
      'images/mi_restaurante/restaurante_banner2.jpg',
      'images/mi_restaurante/restaurante_banner3.jpg',
    ],
    contactName: 'Carlos Méndez',
    contactPhotoAsset: 'images/mi_restaurante/restaurante_banner3.jpg',
    instagram: '@sazonlocal',
    facebook: 'SazonLocal',
    phone: '+57 302 456 7890',
    address: 'Carrera 15 #22-33',
    description:
        'Sabores de casa, platos abundantes y recetas tradicionales con presentación actual.',
    tags: ['local', 'traditional', 'comfort'],
    mapX: 0.38,
    mapY: 0.64,
    latitude: 1.2147,
    longitude: -77.27788,
  ),
  Restaurant(
    id: 4,
    name: 'Veggie Heaven',
    cuisine: 'healthy',
    priceRange: r'$$$',
    rating: 4.7,
    deliveryTime: '20 min',
    logoAsset: 'images/vegano/logo__vegan.png',
    bannerAssets: [
      'images/vegano/vegan_banner1.jpg',
      'images/vegano/vegan_banner2.jpg',
    ],
    contactName: 'Laura Vega',
    contactPhotoAsset: 'images/vegano/vegan_banner1.jpg',
    instagram: '@veggieheaven',
    facebook: 'VeggieHeaven',
    phone: '+57 303 123 4567',
    address: 'Calle 8 #12-34',
    description:
        'Cocina vegetal fresca con bowls, tostadas y platos ligeros pensados para repetir.',
    tags: ['healthy', 'vegan', 'fresh'],
    mapX: 0.72,
    mapY: 0.54,
    latitude: 1.22629,
    longitude: -77.28592,
  ),
  Restaurant(
    id: 5,
    name: 'Mi Restaurante',
    cuisine: 'local',
    priceRange: r'$$$',
    rating: 4.7,
    deliveryTime: '20 min',
    logoAsset: 'images/mi_restaurante/logo_restaurante.png',
    bannerAssets: [
      'images/mi_restaurante/restaurante_banner1.jpg',
      'images/mi_restaurante/restaurante_banner2.jpg',
      'images/mi_restaurante/restaurante_banner3.jpg',
    ],
    contactName: 'Chef de la Casa',
    contactPhotoAsset: 'images/mi_restaurante/restaurante_banner1.jpg',
    instagram: '@mirestaurante',
    facebook: 'MiRestaurante',
    phone: '+57 304 456 8890',
    address: 'Boulevard Gastronómico 51',
    description:
        'Cocina casual premium con enfoque en experiencia de sala, productos nobles y servicio cuidado.',
    tags: ['local', 'premium', 'chef'],
    mapX: 0.82,
    mapY: 0.34,
    latitude: 1.22806,
    longitude: -77.27731,
    isHot: true,
  ),
  Restaurant(
    id: 6,
    name: 'Papas Town',
    cuisine: 'fast',
    priceRange: r'$',
    rating: 4.4,
    deliveryTime: '18-26 min',
    logoAsset: 'images/resto_papas/logoapp1.png',
    bannerAssets: [
      'images/resto_papas/banner_papas.jpg',
      'images/resto_papas/banner_papas1.jpg',
    ],
    contactName: 'Valentina Rosero',
    contactPhotoAsset: 'images/resto_papas/banner_papas1.jpg',
    instagram: '@papastown.pasto',
    facebook: 'PapasTownPasto',
    phone: '+57 315 884 2201',
    address: 'Cra. 24 #18-41, San Juan de Pasto',
    description:
        'Papas cargadas, salsas fuertes y formato directo para pedidos rápidos y nocturnos.',
    tags: ['fast', 'street', 'papas'],
    mapX: 0.48,
    mapY: 0.50,
    latitude: 1.21543,
    longitude: -77.28364,
    isHot: true,
  ),
  Restaurant(
    id: 7,
    name: 'Costa Brava Pasto',
    cuisine: 'local',
    priceRange: r'$$',
    rating: 4.6,
    deliveryTime: '24-32 min',
    logoAsset: 'images/el_tambeno/el_tambeno_logo.png',
    bannerAssets: [
      'images/el_tambeno/tambeno_banner2.jpg',
      'images/el_tambeno/tambeno_plato3.jpg',
      'images/el_tambeno/tambeno_plato4.jpg',
    ],
    contactName: 'Samuel Cabrera',
    contactPhotoAsset: 'images/el_tambeno/tambeno_banner3.jpg',
    instagram: '@costabrava.pasto',
    facebook: 'CostaBravaPasto',
    phone: '+57 316 772 1408',
    address: 'Calle 19 #30-15, San Juan de Pasto',
    description:
        'Pescados, arroces y platos marinos con emplatado moderno y servicio orientado a delivery.',
    tags: ['seafood', 'local', 'premium'],
    mapX: 0.30,
    mapY: 0.28,
    latitude: 1.21854,
    longitude: -77.27321,
  ),
  Restaurant(
    id: 8,
    name: 'Trigo y Fuego',
    cuisine: 'local',
    priceRange: r'$$',
    rating: 4.5,
    deliveryTime: '22-30 min',
    logoAsset: 'images/mi_restaurante/logo_restaurante.png',
    bannerAssets: [
      'images/mi_restaurante/restaurante_banner3.jpg',
      'images/mi_restaurante/restaurante_plato1.jpg',
      'images/mi_restaurante/restaurante_plato2.jpg',
    ],
    contactName: 'María del Pilar Erazo',
    contactPhotoAsset: 'images/mi_restaurante/restaurante_banner2.jpg',
    instagram: '@trigoyfuego',
    facebook: 'TrigoYFuego',
    phone: '+57 318 554 4409',
    address: 'Av. Panamericana #12-90, San Juan de Pasto',
    description:
        'Sándwiches calientes, bowls de autor y panadería salada con un perfil urbano.',
    tags: ['street', 'premium', 'comfort'],
    mapX: 0.66,
    mapY: 0.70,
    latitude: 1.20984,
    longitude: -77.28971,
  ),
];

const featuredRestaurantIds = <int>[1, 3, 2, 4, 5];

const promotions = <PromoCampaign>[
  PromoCampaign(
    id: 1,
    restaurantId: 1,
    imageAsset: 'images/el_tambeno/tambeno_banner.jpg',
    title: 'Restaurante El Tambello',
    description:
        '2x1 en platos seleccionados y entradas para compartir hasta fin de mes.',
  ),
  PromoCampaign(
    id: 2,
    restaurantId: 2,
    imageAsset: 'images/burguer_house/banner_burguer.jpg',
    title: 'Burger Lab',
    description:
        'Combo especial con burger, papas y bebida por precio lanzamiento.',
  ),
  PromoCampaign(
    id: 3,
    restaurantId: 3,
    imageAsset: 'images/resto_papas/banner_papas.jpg',
    title: 'Sazón Local',
    description:
        '15% off en tu primera orden con platos caseros y menú del día.',
  ),
  PromoCampaign(
    id: 4,
    restaurantId: 4,
    imageAsset: 'images/vegano/vegan_banner2.jpg',
    title: 'Veggie Heaven',
    description: '20% de descuento en bowls saludables y opciones plant-based.',
  ),
];

const recommendedDishes = <RecommendedDish>[
  RecommendedDish(
    id: 1,
    restaurantId: 1,
    dishName: 'Crispetas de pollo',
    imageAsset: 'images/el_tambeno/tambeno_plato1.jpg',
    price: 12.99,
    restaurantName: 'Restaurante El Tambello',
    description:
        'Trozos crujientes con salsa de la casa, ideales para picar y arrancar con fuerza.',
  ),
  RecommendedDish(
    id: 2,
    restaurantId: 1,
    dishName: 'Rollo carne de res',
    imageAsset: 'images/el_tambeno/tambeno_plato2.jpg',
    price: 14.99,
    restaurantName: 'Restaurante El Tambello',
    description:
        'Carne condimentada, papas rústicas y un perfil ahumado muy marcado.',
  ),
  RecommendedDish(
    id: 3,
    restaurantId: 2,
    dishName: 'Clásica Burger',
    imageAsset: 'images/burguer_house/banner_burguer1.jpg',
    price: 9.99,
    restaurantName: 'Burger Lab',
    description:
        'Burger de res con vegetales frescos, cebolla caramelizada y salsa secreta.',
  ),
  RecommendedDish(
    id: 4,
    restaurantId: 3,
    dishName: 'Tacos al pastor',
    imageAsset: 'images/mi_restaurante/restaurante_banner2.jpg',
    price: 8.99,
    restaurantName: 'Sazón Local',
    description:
        'Tres tacos con piña, cilantro y salsa verde para un bocado directo y clásico.',
  ),
  RecommendedDish(
    id: 5,
    restaurantId: 4,
    dishName: 'Bowl vegano',
    imageAsset: 'images/vegano/vegan_banner2.jpg',
    price: 11.99,
    restaurantName: 'Veggie Heaven',
    description:
        'Quinoa, aguacate, garbanzos crujientes y aderezo cremoso de tahini.',
  ),
  RecommendedDish(
    id: 6,
    restaurantId: 1,
    dishName: 'Chuleta de pescado',
    imageAsset: 'images/el_tambeno/tambeno_plato3.jpg',
    price: 14.99,
    restaurantName: 'Restaurante El Tambello',
    description:
        'Pescado a la plancha, arroz de coco y un montaje fresco con notas cítricas.',
  ),
  RecommendedDish(
    id: 7,
    restaurantId: 1,
    dishName: 'Seviche de camarones',
    imageAsset: 'images/el_tambeno/tambeno_plato4.jpg',
    price: 14.99,
    restaurantName: 'Restaurante El Tambello',
    description:
        'Camarones marinados al limón con cebolla morada y un picante sutil.',
  ),
  RecommendedDish(
    id: 8,
    restaurantId: 6,
    dishName: 'Papas loaded spicy',
    imageAsset: 'images/resto_papas/banner_papas.jpg',
    price: 13.50,
    restaurantName: 'Papas Town',
    description:
        'Papas crujientes con queso fundido, toques ahumados y salsa picante.',
  ),
  RecommendedDish(
    id: 9,
    restaurantId: 7,
    dishName: 'Arroz marinero Costa',
    imageAsset: 'images/el_tambeno/tambeno_plato3.jpg',
    price: 18.90,
    restaurantName: 'Costa Brava Pasto',
    description:
        'Arroz de mar con camarón y pescado, pensado para pedidos de mediodía.',
  ),
  RecommendedDish(
    id: 10,
    restaurantId: 8,
    dishName: 'Sandwich Trigo y Fuego',
    imageAsset: 'images/mi_restaurante/restaurante_plato1.jpg',
    price: 14.20,
    restaurantName: 'Trigo y Fuego',
    description:
        'Pan tostado, carne al grill y un armado contundente para tarde o noche.',
  ),
];

const socialClips = <SocialClip>[
  SocialClip(
    id: 'clip-1',
    restaurantId: 2,
    title: 'Smash de la casa en 20 segundos',
    author: 'Burger Lab Studio',
    coverImage: 'images/burguer_house/banner_burguer2.jpg',
    durationLabel: '0:20',
    viewsLabel: '18.4k',
    likesLabel: '2.1k',
    commentsLabel: '148',
  ),
  SocialClip(
    id: 'clip-2',
    restaurantId: 1,
    title: 'Ceviche con montaje final',
    author: 'Chef Mario Rossi',
    coverImage: 'images/el_tambeno/tambeno_plato4.jpg',
    durationLabel: '0:15',
    viewsLabel: '11.2k',
    likesLabel: '1.4k',
    commentsLabel: '92',
  ),
  SocialClip(
    id: 'clip-3',
    restaurantId: 4,
    title: 'Bowl verde listo para delivery',
    author: 'Veggie Heaven',
    coverImage: 'images/vegano/vegan_banner2.jpg',
    durationLabel: '0:17',
    viewsLabel: '9.8k',
    likesLabel: '870',
    commentsLabel: '54',
  ),
];

const foodPosts = <FoodPost>[
  FoodPost(
    id: 'post-1',
    restaurantId: 1,
    restaurantName: 'Restaurante El Tambello',
    author: 'Chef Mario Rossi',
    authorRole: 'Creador del menú',
    imageAsset: 'images/el_tambeno/tambeno_plato2.jpg',
    caption:
        'Cocción alta, textura firme y salida perfecta para compartir. Hoy está rompiendo en pedidos nocturnos.',
    likesLabel: '2.3k',
    commentsLabel: '184',
    tags: ['trend', 'chef special', 'top seller'],
  ),
  FoodPost(
    id: 'post-2',
    restaurantId: 2,
    restaurantName: 'Burger Lab',
    author: 'Burger Lab',
    authorRole: 'Marca',
    imageAsset: 'images/burguer_house/banner_burguer1.jpg',
    caption:
        'Pan brioche brillante, doble capa de sabor y papas listas para ruta rápida.',
    likesLabel: '5.1k',
    commentsLabel: '420',
    tags: ['burger', 'combo', 'delivery'],
  ),
  FoodPost(
    id: 'post-3',
    restaurantId: 3,
    restaurantName: 'Sazón Local',
    author: 'Carlos Méndez',
    authorRole: 'Cocina local',
    imageAsset: 'images/mi_restaurante/restaurante_banner2.jpg',
    caption:
        'Tacos al pastor saliendo con piña fresca, cilantro y salsa verde para quienes quieren algo directo y clásico.',
    likesLabel: '1.6k',
    commentsLabel: '95',
    tags: ['local', 'street food', 'fresh'],
  ),
  FoodPost(
    id: 'post-4',
    restaurantId: 4,
    restaurantName: 'Veggie Heaven',
    author: 'Laura Vega',
    authorRole: 'Healthy creator',
    imageAsset: 'images/vegano/vegan_banner1.jpg',
    caption:
        'Bowl fresco, colores limpios y montaje pensado para que llegue bonito incluso en delivery.',
    likesLabel: '980',
    commentsLabel: '61',
    tags: ['healthy', 'vegan', 'fresh'],
  ),
  FoodPost(
    id: 'post-5',
    restaurantId: 6,
    restaurantName: 'Papas Town',
    author: 'Valentina Rosero',
    authorRole: 'Street kitchen',
    imageAsset: 'images/resto_papas/banner_papas1.jpg',
    caption:
        'Papas cargadas saliendo con queso fundido y salsas fuertes para la noche. Directo y sin vueltas.',
    likesLabel: '1.2k',
    commentsLabel: '88',
    tags: ['street', 'papas', 'late night'],
  ),
];

const initialRestaurantComments = <RestaurantComment>[
  RestaurantComment(
    id: 'comment-1',
    restaurantId: 1,
    author: 'Andrea P.',
    handle: '@andreacome',
    message:
        'El ceviche llega muy bien presentado y el punto del limón está brutal. Lo volvería a pedir.',
    timeLabel: 'Hace 12 min',
    likesLabel: '24',
  ),
  RestaurantComment(
    id: 'comment-2',
    restaurantId: 2,
    author: 'Santi Foodie',
    handle: '@santiburgers',
    message:
        'La smash tiene buena costra y las papas sí llegan crocantes. Tremendo combo.',
    timeLabel: 'Hace 20 min',
    likesLabel: '41',
  ),
  RestaurantComment(
    id: 'comment-3',
    restaurantId: 3,
    author: 'Luisa M.',
    handle: '@lucome_local',
    message:
        'Ideal para almuerzo. Porción generosa, sabor casero y entrega puntual.',
    timeLabel: 'Hace 35 min',
    likesLabel: '18',
  ),
  RestaurantComment(
    id: 'comment-4',
    restaurantId: 5,
    author: 'Pipe R.',
    handle: '@pipegourmet',
    message:
        'Se siente premium desde el empaque. Buen sitio para pedir algo más especial.',
    timeLabel: 'Hace 1 h',
    likesLabel: '29',
  ),
];

const liveMapSnapshot = DeliveryMapSnapshot(
  title: 'Seguimiento en vivo',
  status: 'Repartidor cerca de ti',
  eta: '12 min',
  courierName: 'Jhon en moto',
  pickupLabel: 'Burger Lab · cocina lista',
  dropoffLabel: 'Cra. 15 #22-33 · entrega',
  progress: 0.68,
);

const paymentMethods = <PaymentMethodOption>[
  PaymentMethodOption(
    type: PaymentMethodType.card,
    label: 'Tarjeta terminada en 4821',
    subtitle: 'Visa crédito · pago rápido',
  ),
  PaymentMethodOption(
    type: PaymentMethodType.nequi,
    label: 'Nequi',
    subtitle: 'Requiere comprobante para validación',
  ),
  PaymentMethodOption(
    type: PaymentMethodType.bankTransfer,
    label: 'Transferencia bancaria',
    subtitle: 'Adjunta consignación o soporte',
  ),
  PaymentMethodOption(
    type: PaymentMethodType.wallet,
    label: 'Wallet La Carta',
    subtitle: 'Saldo promocional y cashback',
  ),
  PaymentMethodOption(
    type: PaymentMethodType.instant,
    label: 'Transferencia inmediata',
    subtitle: 'Validación express interna',
  ),
  PaymentMethodOption(
    type: PaymentMethodType.cash,
    label: 'Efectivo contra entrega',
    subtitle: 'Paga al recibir el pedido',
  ),
];

const mealWindows = <MealWindow>[
  MealWindow(
    id: 'breakfast',
    label: '07:00',
    headline: 'Desayuno recomendado',
    startHour: 5,
    endHour: 10,
    restaurantIds: [4, 3, 5],
  ),
  MealWindow(
    id: 'lunch',
    label: '12:00',
    headline: 'Almuerzo fuerte',
    startHour: 11,
    endHour: 16,
    restaurantIds: [3, 1, 5],
  ),
  MealWindow(
    id: 'dinner',
    label: '19:00',
    headline: 'Cena top del día',
    startHour: 17,
    endHour: 23,
    restaurantIds: [2, 1, 5],
  ),
];

const menuItemsByRestaurant = <int, List<MenuItemModel>>{
  1: [
    MenuItemModel(
      restaurantId: 1,
      name: 'Crispetas de pollo',
      price: 12.99,
      description: 'Crujientes, jugosas y con salsa cremosa de la casa.',
      coverImage: 'images/el_tambeno/tambeno_plato1.jpg',
      galleryImages: [
        'images/el_tambeno/tambeno_plato1.jpg',
        'images/el_tambeno/tambeno_plato5.jpg',
        'images/el_tambeno/tambeno_plato6.jpg',
      ],
      ingredients: ['Pollo', 'Empanizado especiado', 'Salsa de la casa'],
      calories: '850 kcal',
      prepTime: '15 min',
      customizations: ['Salsa extra +2', 'Papas rústicas +3', 'Picante medio'],
    ),
    MenuItemModel(
      restaurantId: 1,
      name: 'Rollo carne de res',
      price: 14.99,
      description: 'Carne sazonada con perfil ahumado y guarnición crocante.',
      coverImage: 'images/el_tambeno/tambeno_plato2.jpg',
      galleryImages: [
        'images/el_tambeno/tambeno_plato2.jpg',
        'images/el_tambeno/tambeno_plato9.jpg',
        'images/el_tambeno/tambeno_plato10.jpg',
      ],
      ingredients: ['Res', 'Especias', 'Papas', 'Vegetales'],
      calories: '980 kcal',
      prepTime: '18 min',
      customizations: ['Extra carne +4', 'Queso fundido +2', 'Ajo asado +1'],
    ),
    MenuItemModel(
      restaurantId: 1,
      name: 'Chuleta de pescado',
      price: 14.99,
      description: 'Pescado fresco con punto exacto de plancha y limón.',
      coverImage: 'images/el_tambeno/tambeno_plato3.jpg',
      galleryImages: [
        'images/el_tambeno/tambeno_plato3.jpg',
        'images/el_tambeno/tambeno_plato12.jpg',
        'images/el_tambeno/tambeno_plato13.jpg',
      ],
      ingredients: ['Pescado', 'Ajo', 'Limón', 'Hierbas'],
      calories: '720 kcal',
      prepTime: '20 min',
      customizations: [
        'Salsa tártara +1',
        'Arroz de coco +2',
        'Ensalada fresca',
      ],
    ),
    MenuItemModel(
      restaurantId: 1,
      name: 'Seviche de camarones',
      price: 14.99,
      description: 'Fresco, ácido y con textura firme en cada bocado.',
      coverImage: 'images/el_tambeno/tambeno_plato4.jpg',
      galleryImages: [
        'images/el_tambeno/tambeno_plato4.jpg',
        'images/el_tambeno/tambeno_plato15.jpg',
        'images/el_tambeno/tambeno_plato16.jpg',
      ],
      ingredients: ['Camarones', 'Limón', 'Cebolla morada', 'Cilantro'],
      calories: '450 kcal',
      prepTime: '15 min',
      customizations: ['Más picante +1', 'Aguacate +2', 'Tostadas adicionales'],
    ),
  ],
  2: [
    MenuItemModel(
      restaurantId: 2,
      name: 'Clásica Burger',
      price: 9.99,
      description: 'Carne 180g, vegetales frescos y salsa secreta.',
      coverImage: 'images/burguer_house/banner_burguer2.jpg',
      galleryImages: [
        'images/burguer_house/banner_burguer.jpg',
        'images/burguer_house/banner_burguer1.jpg',
        'images/burguer_house/banner_burguer2.jpg',
      ],
      ingredients: ['Pan brioche', 'Carne de res', 'Lechuga', 'Tomate'],
      calories: '720 kcal',
      prepTime: '12 min',
      customizations: ['Doble carne +3', 'Tocino +2', 'Aros de cebolla +1.5'],
    ),
  ],
  3: [
    MenuItemModel(
      restaurantId: 3,
      name: 'Tacos al pastor',
      price: 8.99,
      description: 'Tres tacos con piña, cebolla y cilantro.',
      coverImage: 'images/mi_restaurante/restaurante_banner1.jpg',
      galleryImages: [
        'images/mi_restaurante/restaurante_banner1.jpg',
        'images/mi_restaurante/restaurante_banner2.jpg',
        'images/mi_restaurante/restaurante_banner3.jpg',
      ],
      ingredients: ['Cerdo adobado', 'Piña', 'Cebolla', 'Cilantro'],
      calories: '540 kcal',
      prepTime: '10 min',
      customizations: ['Extra salsa +0.5', 'Queso fresco +1.5', 'Guacamole +2'],
    ),
  ],
  4: [
    MenuItemModel(
      restaurantId: 4,
      name: 'Bowl vegano',
      price: 11.99,
      description: 'Quinoa, aguacate y garbanzos con aderezo cremoso.',
      coverImage: 'images/vegano/vegan_banner1.jpg',
      galleryImages: [
        'images/vegano/vegan_banner1.jpg',
        'images/vegano/vegan_banner2.jpg',
      ],
      ingredients: ['Quinoa', 'Aguacate', 'Garbanzos', 'Espinaca', 'Tahini'],
      calories: '590 kcal',
      prepTime: '10 min',
      customizations: ['Tofu marinado +2.5', 'Semillas +1', 'Aderezo extra +1'],
    ),
  ],
  5: [
    MenuItemModel(
      restaurantId: 5,
      name: 'Plato especial',
      price: 15.99,
      description: 'La firma de la casa con montaje limpio y sabores intensos.',
      coverImage: 'images/mi_restaurante/restaurante_banner1.jpg',
      galleryImages: [
        'images/mi_restaurante/restaurante_banner1.jpg',
        'images/mi_restaurante/restaurante_banner2.jpg',
        'images/mi_restaurante/restaurante_banner3.jpg',
      ],
      ingredients: ['Proteína del día', 'Verduras', 'Salsa de autor'],
      calories: '600 kcal',
      prepTime: '15 min',
      customizations: [
        'Extra proteína +3',
        'Salsa aparte',
        'Guarnición premium +2',
      ],
    ),
  ],
  6: [
    MenuItemModel(
      restaurantId: 6,
      name: 'Papas cargadas mixtas',
      price: 13.50,
      description: 'Papas crocantes con cheddar, tocineta y salsa burger.',
      coverImage: 'images/resto_papas/banner_papas.jpg',
      galleryImages: [
        'images/resto_papas/banner_papas.jpg',
        'images/resto_papas/banner_papas1.jpg',
      ],
      ingredients: ['Papas', 'Cheddar', 'Tocineta', 'Salsa especial'],
      calories: '840 kcal',
      prepTime: '14 min',
      customizations: ['Extra queso +2', 'Jalapeños +1', 'Pollo +3'],
    ),
  ],
  7: [
    MenuItemModel(
      restaurantId: 7,
      name: 'Arroz marinero',
      price: 18.90,
      description: 'Arroz húmedo con camarón, pescado y fondo intenso.',
      coverImage: 'images/el_tambeno/tambeno_plato3.jpg',
      galleryImages: [
        'images/el_tambeno/tambeno_plato3.jpg',
        'images/el_tambeno/tambeno_plato4.jpg',
        'images/el_tambeno/tambeno_banner2.jpg',
      ],
      ingredients: ['Arroz', 'Camarón', 'Pescado', 'Aliños'],
      calories: '760 kcal',
      prepTime: '20 min',
      customizations: ['Más camarón +4', 'Ají aparte', 'Patacón +2'],
    ),
  ],
  8: [
    MenuItemModel(
      restaurantId: 8,
      name: 'Sándwich de la casa',
      price: 14.20,
      description: 'Pan tostado, proteína al grill y vegetales con salsa de ajo.',
      coverImage: 'images/mi_restaurante/restaurante_plato1.jpg',
      galleryImages: [
        'images/mi_restaurante/restaurante_plato1.jpg',
        'images/mi_restaurante/restaurante_plato2.jpg',
        'images/mi_restaurante/restaurante_plato3.jpg',
      ],
      ingredients: ['Pan artesanal', 'Proteína al grill', 'Vegetales', 'Salsa'],
      calories: '690 kcal',
      prepTime: '13 min',
      customizations: ['Doble proteína +3', 'Queso +1.5', 'Papas +3'],
    ),
  ],
};

const triviaQuestions = <TriviaQuestion>[
  TriviaQuestion(
    question:
        '¿Cuál es el ingrediente principal de la pasta Carbonara tradicional?',
    options: ['Tomate', 'Huevo y queso pecorino', 'Crema de leche', 'Albahaca'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: '¿De qué país es originaria la paella?',
    options: ['México', 'Italia', 'España', 'Argentina'],
    correctIndex: 2,
  ),
  TriviaQuestion(
    question: '¿Qué queso se usa típicamente en una pizza Margherita?',
    options: ['Cheddar', 'Mozzarella', 'Parmesano', 'Gouda'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: '¿Cuál de estos es un corte de carne japonés famoso?',
    options: ['Wagyu', 'Angus', 'Hereford', 'Charolais'],
    correctIndex: 0,
  ),
  TriviaQuestion(
    question: '¿Qué especia es conocida como el oro rojo?',
    options: ['Cúrcuma', 'Pimentón', 'Azafrán', 'Canela'],
    correctIndex: 2,
  ),
  TriviaQuestion(
    question: '¿Qué bebida fermentada es típica de Japón?',
    options: ['Tequila', 'Sake', 'Soju', 'Baijiu'],
    correctIndex: 1,
  ),
  TriviaQuestion(
    question: '¿Cuál es el plato nacional de Tailandia?',
    options: ['Curry verde', 'Pad Thai', 'Tom Yum', 'Sushi'],
    correctIndex: 1,
  ),
];

const initialAchievements = <Achievement>[
  Achievement(
    name: 'Primer pedido',
    description: 'Confirma tu primera orden dentro de la app.',
  ),
  Achievement(
    name: 'Foodie nivel 2',
    description: 'Supera los 500 puntos acumulados.',
  ),
  Achievement(
    name: 'Ruleta ganador',
    description: 'Gira la ruleta y desbloquea un premio.',
  ),
  Achievement(
    name: 'Explorador de menús',
    description: 'Abre una ficha expandida del menú.',
  ),
  Achievement(
    name: 'Trivia master',
    description: 'Acumula 100 puntos en la trivia gastronómica.',
  ),
];

const initialChallenges = <RewardChallenge>[
  RewardChallenge(
    id: 'two-items',
    title: 'Pide 2 items',
    description: 'Completa un pedido con al menos dos unidades en el carrito.',
    points: 30,
  ),
  RewardChallenge(
    id: 'chat',
    title: 'Chatea con un restaurante',
    description: 'Envía al menos un mensaje al restaurante.',
    points: 15,
  ),
  RewardChallenge(
    id: 'menu',
    title: 'Explora un menú',
    description: 'Abre una ficha expandida de un plato.',
    points: 20,
  ),
  RewardChallenge(
    id: 'trivia',
    title: 'Juega trivia',
    description: 'Responde al menos una pregunta en recompensas.',
    points: 25,
  ),
];

const wheelRewards = <String>[
  '+50 pts',
  'Descuento 10%',
  'Postre gratis',
  '+30 pts',
  'Combo sorpresa',
  '+100 pts',
];
