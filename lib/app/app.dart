import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_controller.dart';
import 'app_data.dart';
import 'models.dart';

const _canvas = Color(0xFFF6F0E8);
const _surface = Color(0xFFFFFCF8);
const _card = Color(0xFFFFFFFF);
const _ink = Color(0xFF231815);
const _muted = Color(0xFF6D625C);
const _coral = Color(0xFFD64045);
const _coralDark = Color(0xFF8F1D26);
const _gold = Color(0xFFE6AF57);
const _olive = Color(0xFF65743A);
const _line = Color(0xFFE8D7C8);

class UrkuFoodApp extends StatelessWidget {
  const UrkuFoodApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _coral,
        brightness: Brightness.light,
        surface: _surface,
      ),
      scaffoldBackgroundColor: _canvas,
      textTheme: GoogleFonts.manropeTextTheme(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'La Carta',
      theme: base.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.sora(
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        cardTheme: CardThemeData(
          color: _card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: _line),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          selectedColor: _coral,
          secondarySelectedColor: _coral,
          side: const BorderSide(color: _line),
          backgroundColor: _surface,
          labelStyle: GoogleFonts.manrope(
            color: _ink,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: _coral.withValues(alpha: 0.14),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? _coral : _muted,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => GoogleFonts.manrope(
              color: states.contains(WidgetState.selected) ? _coral : _muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _coral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: SplashGate(controller: controller),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.controller});

  final AppController controller;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _ready
              ? (widget.controller.isAuthenticated
                    ? UrkuHomeShell(controller: widget.controller)
                    : AuthScreen(controller: widget.controller))
              : const _SplashScreen(),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isRegister = widget.controller.isRegisterMode;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'images/la_carta_intro.png',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  isRegister ? 'Crea tu cuenta' : 'Entra a La Carta',
                  style: GoogleFonts.sora(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accede como en una app de delivery: ubicación, pedidos, social food y mapa de Pasto en un solo flujo.',
                  style: GoogleFonts.manrope(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                if (isRegister) ...[
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      'Nombre completo',
                      Icons.person_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      'Número de WhatsApp',
                      Icons.phone_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Correo electrónico',
                    Icons.alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    'Contraseña',
                    Icons.lock_rounded,
                  ),
                ),
                if (widget.controller.authErrorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(
                      widget.controller.authErrorMessage!,
                      style: GoogleFonts.manrope(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: widget.controller.isAuthBusy ? null : () async {
                    if (isRegister) {
                      await widget.controller.register(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: _phoneController.text,
                      );
                    } else {
                      await widget.controller.signIn(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                    }
                  },
                  icon: Icon(
                    isRegister
                        ? Icons.person_add_alt_1_rounded
                        : Icons.login_rounded,
                  ),
                  label: Text(
                    widget.controller.isAuthBusy
                        ? 'Validando...'
                        : (isRegister ? 'Crear cuenta' : 'Ingresar'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: widget.controller.isAuthBusy
                      ? null
                      : widget.controller.toggleAuthMode,
                  child: Text(
                    isRegister
                        ? 'Ya tengo cuenta, iniciar sesión'
                        : 'No tengo cuenta, registrarme',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coral,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_coral, _coralDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'images/la_carta_intro.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'La Carta',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'URKU Food experience',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UrkuHomeShell extends StatelessWidget {
  const UrkuHomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final radius = MediaQuery.sizeOf(context).width > 720 ? 34.0 : 0.0;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFAF4EC), Color(0xFFF2E7D8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Material(
                    color: _surface,
                    child: Stack(
                      children: [
                        Scaffold(
                          backgroundColor: Colors.transparent,
                          floatingActionButton: controller.cartCount > 0
                              ? FloatingActionButton.extended(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          CartScreen(controller: controller),
                                    ),
                                  ),
                                  backgroundColor: _coral,
                                  foregroundColor: Colors.white,
                                  icon: const Icon(Icons.shopping_bag_rounded),
                                  label: Text(
                                    '${controller.cartCount} · ${_currency(controller.cartTotal)}',
                                  ),
                                )
                              : null,
                          bottomNavigationBar: NavigationBar(
                            selectedIndex: controller.selectedTabIndex,
                            onDestinationSelected: controller.setTab,
                            destinations: const [
                              NavigationDestination(
                                icon: Icon(Icons.home_rounded),
                                label: 'Home',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.storefront_rounded),
                                label: 'Restaurantes',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.play_circle_fill_rounded),
                                label: 'Social',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.map_rounded),
                                label: 'Mapa',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.person_rounded),
                                label: 'Perfil',
                              ),
                            ],
                          ),
                          body: Column(
                            children: [
                              ShellHeader(
                                controller: controller,
                                onCartTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        CartScreen(controller: controller),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IndexedStack(
                                  index: controller.selectedTabIndex,
                                  children: [
                                    HomeView(
                                      controller: controller,
                                      onOpenRestaurant: (restaurant) =>
                                          _openRestaurant(context, restaurant),
                                    ),
                                    RestaurantsView(
                                      controller: controller,
                                      onOpenRestaurant: (restaurant) =>
                                          _openRestaurant(context, restaurant),
                                    ),
                                    SocialView(
                                      controller: controller,
                                      onOpenRestaurant: (restaurant) =>
                                          _openRestaurant(context, restaurant),
                                    ),
                                    MapView(
                                      controller: controller,
                                      onOpenRestaurant: (restaurant) =>
                                          _openRestaurant(context, restaurant),
                                    ),
                                    ProfileView(
                                      controller: controller,
                                      onOpenRestaurant: (restaurant) =>
                                          _openRestaurant(context, restaurant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        NotificationOverlay(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openRestaurant(BuildContext context, Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RestaurantDetailScreen(
          controller: controller,
          restaurant: restaurant,
        ),
      ),
    );
  }
}

class ShellHeader extends StatelessWidget {
  const ShellHeader({
    super.key,
    required this.controller,
    required this.onCartTap,
  });

  final AppController controller;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(color: _surface),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _canvas,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: _coral, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.deliveryAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderBadge(
                icon: Icons.stars_rounded,
                label: '${controller.points}',
              ),
              const SizedBox(height: 8),
              IconButton.filledTonal(
                onPressed: onCartTap,
                style: IconButton.styleFrom(
                  backgroundColor: _canvas,
                  foregroundColor: _coral,
                ),
                icon: Badge(
                  isLabelVisible: controller.cartCount > 0,
                  label: Text(controller.cartCount.toString()),
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeLocationCard extends StatelessWidget {
  const HomeLocationCard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _coral.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.near_me_rounded, color: _coral),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu ubicación actual',
                    style: GoogleFonts.manrope(
                      color: _muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.deliveryAddress,
                    style: GoogleFonts.sora(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.edit_location_alt_rounded),
              label: const Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _canvas,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _coral),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: _ink,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'images/la_carta_intro.png',
        height: 232,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_coralDark, _coral],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -42),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundImage: const AssetImage('images/logoapp.png'),
                    backgroundColor: _canvas,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.currentUserName,
                  style: GoogleFonts.sora(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.currentUserHandle} · fan del delivery, reels de comida y spots guardados',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMetricPill extends StatelessWidget {
  const ProfileMetricPill({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF8), Color(0xFFF6EDE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _coral.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: _coral),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sora(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: _muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryMapCard extends StatelessWidget {
  const DeliveryMapCard({super.key, required this.snapshot});

  final DeliveryMapSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF151515), Color(0xFF2B2B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.map_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.title,
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${snapshot.status} · ${snapshot.eta}',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  snapshot.courierName,
                  style: GoogleFonts.manrope(
                    color: _gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoutePainter(progress: snapshot.progress),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 24,
                    child: _MapPoint(label: 'Pickup', color: _gold),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 22,
                    child: _MapPoint(label: 'Destino', color: _coral),
                  ),
                  Positioned(
                    left: 110 + (snapshot.progress * 90),
                    top: 50 + (snapshot.progress * 18),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        color: _coral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    snapshot.pickupLabel,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    snapshot.dropoffLabel,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPoint extends StatelessWidget {
  const _MapPoint({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final activePaint = Paint()
      ..color = _gold
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = ui.Path()
      ..moveTo(36, 42)
      ..quadraticBezierTo(
        size.width * 0.35,
        18,
        size.width * 0.52,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.82,
        size.width - 36,
        size.height - 34,
      );

    canvas.drawPath(path, basePaint);

    final metrics = path.computeMetrics().first;
    final activePath = metrics.extractPath(
      0,
      metrics.length * progress.clamp(0, 1),
    );
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SocialClipCard extends StatelessWidget {
  const SocialClipCard({super.key, required this.clip, required this.onTap});

  final SocialClip clip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: clip.mediaBytes != null
                    ? Image.memory(clip.mediaBytes!, fit: BoxFit.cover)
                    : Image.asset(clip.coverImage, fit: BoxFit.cover),
              ),
              Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.68),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          Text(
                            clip.durationLabel,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      clip.viewsLabel,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  clip.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  clip.mediaLabel == null
                      ? clip.author
                      : '${clip.author} · ${clip.mediaLabel}',
                  style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodPostCard extends StatelessWidget {
  const FoodPostCard({super.key, required this.post, required this.onTap});

  final FoodPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _surface,
                    backgroundImage: AssetImage(
                      restaurants
                          .firstWhere((r) => r.id == post.restaurantId)
                          .logoAsset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${post.restaurantName} · ${post.authorRole}',
                          style: GoogleFonts.manrope(
                            color: _muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: _muted),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: post.mediaBytes != null
                    ? Image.memory(
                        post.mediaBytes!,
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        post.imageAsset,
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: _coral),
                      const SizedBox(width: 6),
                      Text(
                        post.likesLabel,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.mode_comment_outlined, color: _muted),
                      const SizedBox(width: 6),
                      Text(
                        post.commentsLabel,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.caption,
                    style: GoogleFonts.manrope(
                      color: _ink,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (post.mediaLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Archivo: ${post.mediaLabel}',
                      style: GoogleFonts.manrope(
                        color: _muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags
                        .map(
                          (tag) => Chip(
                            label: Text('#$tag'),
                            backgroundColor: _surface,
                            side: const BorderSide(color: _line),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selectedType,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodOption method;
  final PaymentMethodType selectedType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _coral.withValues(alpha: 0.08) : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _coral : _line),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: selected ? _coral : Colors.white,
              foregroundColor: selected ? Colors.white : _ink,
              child: Icon(_paymentMethodIcon(method.type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method.subtitle,
                    style: GoogleFonts.manrope(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? _coral : _muted, width: 2),
                color: selected ? _coral : Colors.transparent,
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.controller,
    required this.onOpenRestaurant,
  });

  final AppController controller;
  final ValueChanged<Restaurant> onOpenRestaurant;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        const HomeHeroCard(),
        const SizedBox(height: 18),
        HomeLocationCard(controller: controller),
        const SizedBox(height: 18),
        SearchField(
          initialValue: controller.searchQuery,
          hintText: 'Buscar platos o restaurantes',
          onChanged: controller.updateSearch,
        ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'Promos', title: 'Campañas activas'),
        const SizedBox(height: 14),
        PromoCarousel(
          promotions: controller.filteredPromotions,
          onTap: (promo) {
            final restaurant = controller.restaurantById(promo.restaurantId);
            if (restaurant != null) {
              onOpenRestaurant(restaurant);
            }
          },
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Recomendados',
          title: '8 restaurantes para pedir hoy',
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 230,
          child: controller.recommendedRestaurants.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Sin coincidencias',
                  message: 'Prueba otra búsqueda o cambia la categoría activa.',
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.recommendedRestaurants.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final restaurant = controller.recommendedRestaurants[index];
                    final isFavorite = controller.favoriteRestaurantIds
                        .contains(restaurant.id);
                    return FeaturedRestaurantCard(
                      restaurant: restaurant,
                      isFavorite: isFavorite,
                      onTap: () => onOpenRestaurant(restaurant),
                      onFavoriteTap: () =>
                          controller.toggleFavoriteRestaurant(restaurant.id),
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Mejores platos',
          title: 'Scroll de platos para descubrir',
        ),
        const SizedBox(height: 14),
        ...controller.homeDishFeed.map(
          (dish) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: RecommendedDishCard(
              dish: dish,
              liked: controller.likedRecommendedDishes.contains(dish.dishName),
              onTap: () {
                final restaurant = controller.restaurantById(dish.restaurantId);
                if (restaurant != null) {
                  onOpenRestaurant(restaurant);
                }
              },
              onAdd: () => controller.addRecommendedDish(dish),
              onLike: () => controller.likeRecommendedDish(dish),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Social food',
          title: 'Posts rápidos de la comunidad',
        ),
        const SizedBox(height: 14),
        ...controller.homeSocialFeed.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: FoodPostCard(
              post: post,
              onTap: () {
                final restaurant = controller.restaurantById(post.restaurantId);
                if (restaurant != null) {
                  onOpenRestaurant(restaurant);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HotBadge extends StatelessWidget {
  const _HotBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFF06A23),
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: const Color(0xFFF06A23),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SocialComposerCard extends StatelessWidget {
  const SocialComposerCard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crea un reel o un post',
              style: GoogleFonts.sora(
                color: _ink,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publica contenido asociado a un restaurante y súmalo al feed social de la app.',
              style: GoogleFonts.manrope(
                color: _muted,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showCreateSocialSheet(context, controller, reel: true),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Crear reel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateSocialSheet(
                      context,
                      controller,
                      reel: false,
                    ),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Crear post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SocialView extends StatelessWidget {
  const SocialView({
    super.key,
    required this.controller,
    required this.onOpenRestaurant,
  });

  final AppController controller;
  final ValueChanged<Restaurant> onOpenRestaurant;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        SocialComposerCard(controller: controller),
        const SizedBox(height: 18),
        SearchField(
          initialValue: controller.searchQuery,
          hintText: 'Buscar posts, reels o restaurantes',
          onChanged: controller.updateSearch,
        ),
        const SizedBox(height: 18),
        const SectionTitle(
          eyebrow: 'Reels',
          title: 'Reels creados por la comunidad',
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: controller.filteredSocialClips.isEmpty
              ? const EmptyState(
                  icon: Icons.play_circle_outline_rounded,
                  title: 'Sin reels visibles',
                  message: 'Crea uno nuevo o cambia la búsqueda actual.',
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filteredSocialClips.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final clip = controller.filteredSocialClips[index];
                    return SocialClipCard(
                      clip: clip,
                      onTap: () {
                        final restaurant = controller.restaurantById(
                          clip.restaurantId,
                        );
                        if (restaurant != null) {
                          onOpenRestaurant(restaurant);
                        }
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'Posts', title: 'Lo que más está sonando'),
        const SizedBox(height: 14),
        if (controller.filteredFoodPosts.isEmpty)
          const EmptyState(
            icon: Icons.feed_outlined,
            title: 'Sin posts visibles',
            message: 'Publica algo nuevo o cambia el filtro de búsqueda.',
          )
        else
          ...controller.filteredFoodPosts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FoodPostCard(
                post: post,
                onTap: () {
                  final restaurant = controller.restaurantById(
                    post.restaurantId,
                  );
                  if (restaurant != null) {
                    onOpenRestaurant(restaurant);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.controller,
    required this.onOpenRestaurant,
  });

  final AppController controller;
  final ValueChanged<Restaurant> onOpenRestaurant;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        const SectionTitle(
          eyebrow: 'Mapa gastronómico',
          title: 'OpenStreetMap · San Juan de Pasto',
        ),
        const SizedBox(height: 14),
        RestaurantMapExplorer(
          restaurants: restaurants,
          onTapRestaurant: onOpenRestaurant,
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Ubicaciones',
          title: 'Abre cada punto en OpenStreetMap',
        ),
        const SizedBox(height: 14),
        ...restaurants.map(
          (restaurant) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MapRestaurantCard(
              restaurant: restaurant,
              onTap: () => onOpenRestaurant(restaurant),
              onOpenMaps: () => _openMapsForRestaurant(context, restaurant),
            ),
          ),
        ),
      ],
    );
  }
}

class RestaurantsView extends StatelessWidget {
  const RestaurantsView({
    super.key,
    required this.controller,
    required this.onOpenRestaurant,
  });

  final AppController controller;
  final ValueChanged<Restaurant> onOpenRestaurant;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        SearchField(
          initialValue: controller.searchQuery,
          hintText: 'Buscar restaurantes, estilos o etiquetas',
          onChanged: controller.updateSearch,
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: restaurantFilters.map((filter) {
              final selected = controller.selectedRestaurantFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: selected,
                  label: Text(restaurantFilterLabels[filter] ?? filter),
                  onSelected: (_) => controller.setRestaurantFilter(filter),
                  selectedColor: _coral,
                  backgroundColor: _surface,
                  labelStyle: GoogleFonts.manrope(
                    color: selected ? Colors.white : _ink,
                    fontWeight: FontWeight.w800,
                  ),
                  side: const BorderSide(color: _line),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        ...controller.filteredRestaurants.map(
          (restaurant) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: RestaurantCard(
              restaurant: restaurant,
              isFavorite: controller.favoriteRestaurantIds.contains(
                restaurant.id,
              ),
              onTap: () => onOpenRestaurant(restaurant),
              onFavoriteTap: () =>
                  controller.toggleFavoriteRestaurant(restaurant.id),
            ),
          ),
        ),
        if (controller.filteredRestaurants.isEmpty)
          const EmptyState(
            icon: Icons.storefront_outlined,
            title: 'No encontramos restaurantes',
            message:
                'Cambia el filtro activo o revisa el texto que escribiste.',
          ),
      ],
    );
  }
}

class RewardsView extends StatelessWidget {
  const RewardsView({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        RewardPointsCard(controller: controller),
        const SizedBox(height: 20),
        TriviaCard(controller: controller),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Retos activos',
          title: 'Suma puntos rápido',
        ),
        const SizedBox(height: 12),
        ...controller.challenges.map(
          (challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChallengeCard(
              challenge: challenge,
              onComplete: challenge.completed
                  ? null
                  : () => controller.completeChallenge(challenge.id),
            ),
          ),
        ),
        const SizedBox(height: 24),
        RewardWheelCard(controller: controller),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Premios desbloqueados',
          title: 'Tu colección',
        ),
        const SizedBox(height: 12),
        if (controller.unlockedRewards.isEmpty)
          const EmptyState(
            icon: Icons.card_giftcard_rounded,
            title: 'Aún no hay premios',
            message:
                'Gira la ruleta o completa retos para empezar a desbloquearlos.',
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.unlockedRewards.map((reward) {
              return Chip(
                avatar: const Icon(
                  Icons.workspace_premium_rounded,
                  color: _coral,
                  size: 18,
                ),
                label: Text(reward),
                backgroundColor: _card,
                side: const BorderSide(color: _line),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.controller,
    required this.onOpenRestaurant,
  });

  final AppController controller;
  final ValueChanged<Restaurant> onOpenRestaurant;

  @override
  Widget build(BuildContext context) {
    final favoriteRestaurants = restaurants
        .where(
          (restaurant) =>
              controller.favoriteRestaurantIds.contains(restaurant.id),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        ProfileHeroCard(controller: controller),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentUserName,
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${controller.currentUserHandle} · Nivel ${controller.levelNumber} ${controller.levelName}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: _coral,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Perfil estilo social para guardar favoritos, mostrar actividad y seguir descubriendo restaurantes.',
                  style: GoogleFonts.manrope(color: _muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ProfileMetricPill(
                        label: 'Pedidos',
                        value: '${controller.orderHistory.length}',
                        icon: Icons.shopping_bag_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ProfileMetricPill(
                        label: 'Posts',
                        value: '${controller.createdPostsCount}',
                        icon: Icons.grid_view_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ProfileMetricPill(
                        label: 'Reels',
                        value: '${controller.createdClipsCount}',
                        icon: Icons.play_circle_fill_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ContactRow(
                  icon: Icons.home_rounded,
                  text: controller.deliveryAddress,
                ),
                const SizedBox(height: 8),
                const ContactRow(
                  icon: Icons.info_outline_rounded,
                  text:
                      'Fan de descubrir platos, guardar spots y comentar pedidos.',
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => controller.signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'En curso', title: 'Pedidos activos'),
        const SizedBox(height: 12),
        if (controller.activeOrders.isEmpty)
          const EmptyState(
            icon: Icons.delivery_dining_rounded,
            title: 'Sin pedidos activos',
            message: 'Cuando confirmes un pedido, su estado aparecerá aquí.',
          )
        else
          ...controller.activeOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.orderCode,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          _OrderStatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        order.restaurantNames.join(' · '),
                        style: GoogleFonts.manrope(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${order.itemCount} productos · ETA ${order.etaLabel}',
                        style: GoogleFonts.manrope(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.deliveryAddress,
                        style: GoogleFonts.manrope(color: _muted, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.reorderOrder(order),
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('Repetir'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => controller.refreshOrders(),
                              icon: const Icon(Icons.sync_rounded),
                              label: const Text('Sincronizar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'Historial', title: 'Tus pedidos'),
        const SizedBox(height: 12),
        if (controller.orderHistory.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'Sin pedidos todavía',
            message: 'Cuando confirmes tu primera orden, aparecerá aquí.',
          )
        else
          ...controller.orderHistory.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${order.orderCode} · ${_date(order.createdAt)}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const Spacer(),
                          _OrderStatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        order.items
                            .map((item) => '${item.quantity}x ${item.name}')
                            .join(' · '),
                        style: GoogleFonts.manrope(color: _muted, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      SummaryRow(
                        label: 'Pago',
                        value: _paymentMethodLabel(order.paymentMethod),
                      ),
                      const SizedBox(height: 8),
                      SummaryRow(
                        label: 'Total',
                        value: _currency(order.total),
                        emphasis: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.deliveryAddress,
                        style: GoogleFonts.manrope(color: _muted),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => controller.reorderOrder(order),
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Pedir de nuevo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        const SectionTitle(
          eyebrow: 'Favoritos',
          title: 'Restaurantes guardados',
        ),
        const SizedBox(height: 12),
        if (favoriteRestaurants.isEmpty)
          const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No hay favoritos',
            message:
                'Marca restaurantes o dale like a platos para llenar esta sección.',
          )
        else
          ...favoriteRestaurants.map(
            (restaurant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(
                restaurant: restaurant,
                isFavorite: true,
                onTap: () => onOpenRestaurant(restaurant),
                onFavoriteTap: () =>
                    controller.toggleFavoriteRestaurant(restaurant.id),
              ),
            ),
          ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'Logros', title: 'Progreso desbloqueable'),
        const SizedBox(height: 12),
        ...controller.achievements.map(
          (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AchievementTile(achievement: achievement),
          ),
        ),
      ],
    );
  }
}

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.controller,
    required this.restaurant,
  });

  final AppController controller;
  final Restaurant restaurant;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  var _selectedSection = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final restaurant = widget.restaurant;
    final menuItems = controller.menuForRestaurant(restaurant.id);
    final restaurantClips = controller.clipsForRestaurant(restaurant.id);
    final restaurantPosts = controller.postsForRestaurant(restaurant.id);
    final restaurantComments = controller.commentsForRestaurant(restaurant.id);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final favorite = controller.favoriteRestaurantIds.contains(
          restaurant.id,
        );
        return Scaffold(
          backgroundColor: _canvas,
          appBar: AppBar(
            title: Text(restaurant.name),
            actions: [
              IconButton(
                onPressed: () =>
                    controller.toggleFavoriteRestaurant(restaurant.id),
                icon: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CartScreen(controller: controller),
                  ),
                ),
                icon: Badge(
                  isLabelVisible: controller.cartCount > 0,
                  label: Text(controller.cartCount.toString()),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(
                          controller: controller,
                          restaurant: restaurant,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Chatear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CartScreen(controller: controller),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: Text(
                      'Ver carrito${controller.cartCount > 0 ? ' (${controller.cartCount})' : ''}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              GalleryCarousel(
                images: restaurant.bannerAssets,
                height: 250,
                showArrows: true,
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              restaurant.logoAsset,
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: GoogleFonts.sora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '⭐ ${restaurant.rating} · ${restaurant.deliveryTime} · ${restaurant.priceRange}',
                                  style: GoogleFonts.manrope(
                                    color: _coral,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        restaurant.description,
                        style: GoogleFonts.manrope(color: _muted, height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileMetricPill(
                              label: 'Reels',
                              value: '${restaurantClips.length}',
                              icon: Icons.play_circle_fill_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProfileMetricPill(
                              label: 'Posts',
                              value: '${restaurantPosts.length}',
                              icon: Icons.grid_view_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProfileMetricPill(
                              label: 'Comentarios',
                              value: '${restaurantComments.length}',
                              icon: Icons.mode_comment_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: restaurant.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag.toUpperCase()),
                                backgroundColor: _surface,
                                side: const BorderSide(color: _line),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: _selectedSection == 0,
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('Menú', textAlign: TextAlign.center),
                      ),
                      onSelected: (_) => setState(() => _selectedSection = 0),
                      selectedColor: _coral,
                      labelStyle: GoogleFonts.manrope(
                        color: _selectedSection == 0 ? Colors.white : _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      selected: _selectedSection == 1,
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('Social', textAlign: TextAlign.center),
                      ),
                      onSelected: (_) => setState(() => _selectedSection = 1),
                      selectedColor: _coral,
                      labelStyle: GoogleFonts.manrope(
                        color: _selectedSection == 1 ? Colors.white : _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      selected: _selectedSection == 2,
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('Contacto', textAlign: TextAlign.center),
                      ),
                      onSelected: (_) => setState(() => _selectedSection = 2),
                      selectedColor: _coral,
                      labelStyle: GoogleFonts.manrope(
                        color: _selectedSection == 2 ? Colors.white : _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_selectedSection == 0)
                if (menuItems.isEmpty)
                  const EmptyState(
                    icon: Icons.menu_book_rounded,
                    title: 'Menú no disponible',
                    message:
                        'Este restaurante aún no tiene platos cargados en la aplicación.',
                  )
                else
                  ...menuItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: MenuItemCard(
                        item: item,
                        onExpanded: controller.markMenuExplored,
                        onCustomizationTap: controller.addCustomization,
                        onAddToCart: () =>
                            controller.addMenuItem(item, restaurant),
                      ),
                    ),
                  )
              else if (_selectedSection == 1)
                RestaurantSocialSection(
                  restaurant: restaurant,
                  clips: restaurantClips,
                  posts: restaurantPosts,
                  comments: restaurantComments,
                  commentController: _commentController,
                  onLikeComment: (commentId) => controller.toggleCommentLike(
                    restaurantId: restaurant.id,
                    commentId: commentId,
                  ),
                  onSubmitComment: () {
                    controller.addRestaurantComment(
                      restaurantId: restaurant.id,
                      message: _commentController.text,
                    );
                    _commentController.clear();
                  },
                )
              else
                ContactSection(
                  restaurant: restaurant,
                  onOpenMaps: () => _openMapsForRestaurant(context, restaurant),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activePayment = controller.paymentMethodDetails(
          controller.selectedPaymentMethod,
        );
        return Scaffold(
          backgroundColor: _canvas,
          appBar: AppBar(title: const Text('Carrito y pago')),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: FilledButton.icon(
              onPressed: controller.cart.isEmpty
                  ? null
                  : () async {
                      final success = await controller.confirmOrder();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido confirmado y agregado al historial'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.lock_rounded),
              label: Text('Pagar ${_currency(controller.payableTotal)}'),
            ),
          ),
          body: controller.cart.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Carrito vacío',
                    message:
                        'Agrega platos desde el feed o desde el menú de un restaurante.',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.cartHasMultipleRestaurants) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.layers_rounded,
                                      color: Color(0xFFB85A10),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Tienes productos de ${controller.cartRestaurantCount} restaurantes. El pedido se consolidará en una sola compra.',
                                        style: GoogleFonts.manrope(
                                          color: const Color(0xFF8A4A17),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Entrega tipo Rappi',
                                        style: GoogleFonts.sora(
                                          fontWeight: FontWeight.w800,
                                          color: _ink,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${controller.activeMapSnapshot.status} · ${controller.activeMapSnapshot.eta}',
                                        style: GoogleFonts.manrope(
                                          color: _coral,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    activePayment.label.split(' ').first,
                                  ),
                                  backgroundColor: _surface,
                                  side: const BorderSide(color: _line),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: controller.deliveryAddress,
                              onChanged: controller.updateDeliveryAddress,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                              decoration: _inputDecoration(
                                'Dirección de entrega',
                                Icons.location_on_rounded,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: controller.currentUserPhone,
                              onChanged: controller.updateCustomerPhone,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                              decoration: _inputDecoration(
                                'Número del cliente',
                                Icons.phone_rounded,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: controller.deliveryInstructions,
                              onChanged: controller.updateDeliveryInstructions,
                              minLines: 2,
                              maxLines: 3,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                              decoration: _inputDecoration(
                                'Instrucciones para el repartidor',
                                Icons.notes_rounded,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: controller.clearCart,
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    label: const Text('Vaciar carrito'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: controller.addSurpriseOrder,
                                    icon: const Icon(Icons.auto_awesome_rounded),
                                    label: const Text('Agregar sorpresa'),
                                  ),
                                ),
                              ],
                            ),
                            if (controller.selectedPaymentMethod ==
                                    PaymentMethodType.nequi ||
                                controller.selectedPaymentMethod ==
                                    PaymentMethodType.bankTransfer) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                initialValue: controller.paymentReference,
                                onChanged: controller.updatePaymentReference,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                                decoration: _inputDecoration(
                                  'Referencia de pago o comprobante',
                                  Icons.receipt_long_rounded,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                    withData: true,
                                  );
                                  final file = result?.files.single;
                                  if (file?.bytes == null) {
                                    return;
                                  }
                                  controller.setPaymentProof(
                                    bytes: file!.bytes,
                                    label: file.name,
                                  );
                                },
                                icon: const Icon(Icons.upload_file_rounded),
                                label: Text(
                                  controller.paymentProofLabel == null
                                      ? 'Adjuntar comprobante'
                                      : 'Comprobante: ${controller.paymentProofLabel}',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...controller.cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemCard(
                          item: item,
                          onIncrease: () =>
                              controller.increaseCartItem(item.id),
                          onDecrease: () =>
                              controller.decreaseCartItem(item.id),
                          onRemove: () => controller.removeCartItem(item.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Métodos de pago',
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w800,
                                color: _ink,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...paymentMethods.map(
                              (method) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PaymentMethodTile(
                                  method: method,
                                  selectedType:
                                      controller.selectedPaymentMethod,
                                  selected:
                                      method.type ==
                                      controller.selectedPaymentMethod,
                                  onTap: () =>
                                      controller.setPaymentMethod(method.type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: controller.promoCode,
                              onChanged: controller.updatePromoCode,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                              decoration: _inputDecoration(
                                'Cupón o beneficio',
                                Icons.sell_rounded,
                              ).copyWith(suffixText: 'RAPPI15'),
                            ),
                            const SizedBox(height: 18),
                            SummaryRow(
                              label: 'Subtotal',
                              value: _currency(controller.cartTotal),
                            ),
                            const SizedBox(height: 10),
                            SummaryRow(
                              label: 'Domicilio',
                              value: _currency(controller.deliveryFee),
                            ),
                            const SizedBox(height: 10),
                            SummaryRow(
                              label: 'Servicio',
                              value: _currency(controller.serviceFee),
                            ),
                            if (controller.smallOrderFee > 0) ...[
                              const SizedBox(height: 10),
                              SummaryRow(
                                label: 'Pedido pequeño',
                                value: _currency(controller.smallOrderFee),
                              ),
                            ],
                            if (controller.promoDiscount > 0) ...[
                              const SizedBox(height: 10),
                              SummaryRow(
                                label: 'Descuento aplicado',
                                value:
                                    '-${_currency(controller.promoDiscount)}',
                              ),
                            ],
                            const SizedBox(height: 10),
                            SummaryRow(
                              label: 'Pagas con',
                              value: activePayment.label,
                            ),
                            const Divider(height: 28),
                            SummaryRow(
                              label: 'Total',
                              value: _currency(controller.payableTotal),
                              emphasis: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.controller,
    required this.restaurant,
  });

  final AppController controller;
  final Restaurant restaurant;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final messages = widget.controller.chatForRestaurant(
          widget.restaurant.id,
          widget.restaurant.name,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });

        return Scaffold(
          backgroundColor: _canvas,
          appBar: AppBar(title: Text('Chat con ${widget.restaurant.name}')),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(18),
                      itemCount: messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: message.isUser ? _gold : _coral,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Text(
                                message.message,
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _textController,
                        hintText: 'Escribe tu mensaje',
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _send,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(54, 54),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    final message = _textController.text;
    _textController.clear();
    await widget.controller.sendChatMessage(
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      message: message,
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.initialValue,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: _ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.manrope(color: _muted),
        prefixIcon: const Icon(Icons.search_rounded, color: _coral),
        filled: true,
        fillColor: _card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _coral, width: 1.3),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: GoogleFonts.manrope(
            color: _coral,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.sora(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.promotions,
    required this.onTap,
  });

  final List<PromoCampaign> promotions;
  final ValueChanged<PromoCampaign> onTap;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  var _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.promotions.length <= 1) {
      return;
    }
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      final nextPage = (_page + 1) % widget.promotions.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'Sin promociones activas',
        message:
            'Cambia de categoría o vuelve más tarde para revisar nuevas ofertas.',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 308,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _autoPlayTimer?.cancel();
              }
              if (notification is ScrollEndNotification) {
                _startAutoPlay();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.promotions.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (context, index) {
                final promo = widget.promotions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => widget.onTap(promo),
                    borderRadius: BorderRadius.circular(34),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(color: _line),
                        boxShadow: [
                          BoxShadow(
                            color: _coral.withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(promo.imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.16),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'PROMO',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              promo.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_offer_rounded,
                                        color: _coral,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ver restaurante',
                                        style: GoogleFonts.manrope(
                                          color: _ink,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${index + 1}/${widget.promotions.length}',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white.withValues(alpha: 0.84),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.promotions.length, (index) {
            final active = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: active ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [_coral, Color(0xFFF06A23)])
                    : null,
                color: active ? null : _line,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _coral.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class FastDeliveryCard extends StatelessWidget {
  const FastDeliveryCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.description,
    this.accentLabel,
    this.accentColor = const Color(0xFF248043),
    this.accentBackground = const Color(0xFFE8F8EC),
  });

  final Restaurant restaurant;
  final VoidCallback onTap;
  final String description;
  final String? accentLabel;
  final Color accentColor;
  final Color accentBackground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  restaurant.logoAsset,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            accentLabel ?? restaurant.deliveryTime,
                            style: GoogleFonts.manrope(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.manrope(color: _muted, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapRestaurantCard extends StatelessWidget {
  const MapRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.onOpenMaps,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                restaurant.logoAsset,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: GoogleFonts.sora(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      if (restaurant.isHot) const _HotBadge(label: 'Hot'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.address,
                    style: GoogleFonts.manrope(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.storefront_rounded),
                        label: const Text('Ver'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: onOpenMaps,
                        icon: const Icon(Icons.map_rounded),
                        label: const Text('OSM'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantMapExplorer extends StatelessWidget {
  const RestaurantMapExplorer({
    super.key,
    required this.restaurants,
    required this.onTapRestaurant,
  });

  final List<Restaurant> restaurants;
  final ValueChanged<Restaurant> onTapRestaurant;

  @override
  Widget build(BuildContext context) {
    const pastoCenter = LatLng(1.2136, -77.2811);
    return Card(
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFF9F4ED), Color(0xFFF1E2D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: fm.FlutterMap(
                options: const fm.MapOptions(
                  initialCenter: pastoCenter,
                  initialZoom: 13.2,
                  interactionOptions: fm.InteractionOptions(
                    flags: fm.InteractiveFlag.drag |
                        fm.InteractiveFlag.pinchZoom |
                        fm.InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  fm.TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.urkufood',
                  ),
                  fm.MarkerLayer(
                    markers: restaurants.map((restaurant) {
                      return fm.Marker(
                        point: LatLng(restaurant.latitude, restaurant.longitude),
                        width: 122,
                        height: 54,
                        child: GestureDetector(
                          onTap: () => onTapRestaurant(restaurant),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: restaurant.isHot ? _coral : _ink,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      restaurant.isHot
                                          ? Icons.local_fire_department_rounded
                                          : Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        restaurant.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.manrope(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: restaurant.isHot ? _gold : _coral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: _coral),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mapa real de Pasto con OpenStreetMap. Toca un marcador para abrir el restaurante; los de fuego vienen con mayor demanda.',
                        style: GoogleFonts.manrope(
                          color: _ink,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _line
      ..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      final dy = (size.height / 6) * i;
      final dx = (size.width / 6) * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeaturedRestaurantCard extends StatelessWidget {
  const FeaturedRestaurantCard({
    super.key,
    required this.restaurant,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            restaurant.logoAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            onPressed: onFavoriteTap,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _coral,
                            ),
                          ),
                        ),
                      ),
                      if (restaurant.isHot)
                        Positioned(
                          left: 10,
                          top: 10,
                          child: _HotBadge(label: 'Arde'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '⭐ ${restaurant.rating} · ${restaurant.deliveryTime}',
                  style: GoogleFonts.manrope(
                    color: _coral,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(color: _muted, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurpriseCard extends StatelessWidget {
  const SurpriseCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [_coral, _gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modo sorpresa',
              style: GoogleFonts.sora(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Si no sabes qué pedir, la app elige un plato por ti y además te regala puntos extra.',
              style: GoogleFonts.manrope(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _coralDark,
              ),
              onPressed: onPressed,
              icon: const Icon(Icons.casino_rounded),
              label: const Text('Elegir por mí'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedDishCard extends StatelessWidget {
  const RecommendedDishCard({
    super.key,
    required this.dish,
    required this.liked,
    required this.onTap,
    required this.onAdd,
    required this.onLike,
  });

  final RecommendedDish dish;
  final bool liked;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Image.asset(
                dish.imageAsset,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.dishName,
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ),
                      Text(
                        _currency(dish.price),
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _coral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dish.restaurantName,
                    style: GoogleFonts.manrope(
                      color: _coral,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dish.description,
                    style: GoogleFonts.manrope(color: _muted, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Agregar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: onLike,
                        icon: Icon(
                          liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        label: Text(liked ? 'Guardado' : 'Me gusta'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  restaurant.logoAsset,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onFavoriteTap,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _coral,
                          ),
                        ),
                      ],
                    ),
                    if (restaurant.isHot) ...[
                      const SizedBox(height: 4),
                      const _HotBadge(label: 'Vendiendo bastante'),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '⭐ ${restaurant.rating} · ${restaurant.deliveryTime} · ${restaurant.priceRange}',
                      style: GoogleFonts.manrope(
                        color: _coral,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(color: _muted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardPointsCard extends StatelessWidget {
  const RewardPointsCard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFBE3CF), Color(0xFFFFF6E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _coral,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                controller.levelName,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${controller.points} puntos',
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nivel ${controller.levelNumber} · Sigue acumulando para desbloquear premios mayores.',
              style: GoogleFonts.manrope(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: (controller.points % 200) / 200,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(_coral),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriviaCard extends StatelessWidget {
  const TriviaCard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final question = controller.currentTriviaQuestion;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trivia gastronómica',
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Responde bien y suma puntos. Aunque falles, participas y avanzas.',
              style: GoogleFonts.manrope(color: _muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(question.options.length, (index) {
                    final selected = controller.selectedTriviaOption == index;
                    final answered = controller.selectedTriviaOption != null;
                    final isCorrect = question.correctIndex == index;
                    final background = answered
                        ? isCorrect
                              ? const Color(0xFFE5F7EB)
                              : selected
                              ? const Color(0xFFFDE7E7)
                              : _card
                        : _card;
                    final borderColor = answered
                        ? isCorrect
                              ? const Color(0xFF2E9B4C)
                              : selected
                              ? _coral
                              : _line
                        : _line;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: answered
                            ? null
                            : () => controller.answerTrivia(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _gold.withValues(alpha: 0.25),
                                foregroundColor: _ink,
                                child: Text(String.fromCharCode(65 + index)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: GoogleFonts.manrope(
                                    color: _ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (controller.selectedTriviaOption != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: controller.lastTriviaAnswerCorrect == true
                      ? const Color(0xFFE5F7EB)
                      : const Color(0xFFFDE7E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  controller.lastTriviaAnswerCorrect == true
                      ? 'Respuesta correcta. Ganaste 25 puntos.'
                      : 'No era esa. La correcta es ${question.options[question.correctIndex]}. Ganaste 5 puntos por participar.',
                  style: GoogleFonts.manrope(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.nextTriviaQuestion,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  'Siguiente pregunta · ${controller.triviaScore} pts',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  final RewardChallenge challenge;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: challenge.completed ? const Color(0xFFE5F7EB) : _surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                challenge.completed
                    ? Icons.check_circle_rounded
                    : Icons.bolt_rounded,
                color: challenge.completed ? const Color(0xFF2E9B4C) : _coral,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: GoogleFonts.manrope(color: _muted, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            challenge.completed
                ? Chip(
                    label: const Text('Completado'),
                    backgroundColor: const Color(0xFFE5F7EB),
                    side: BorderSide.none,
                    labelStyle: GoogleFonts.manrope(
                      color: const Color(0xFF2E9B4C),
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : FilledButton(
                    onPressed: onComplete,
                    child: Text('+${challenge.points} pts'),
                  ),
          ],
        ),
      ),
    );
  }
}

class RewardWheelCard extends StatefulWidget {
  const RewardWheelCard({super.key, required this.controller});

  final AppController controller;

  @override
  State<RewardWheelCard> createState() => _RewardWheelCardState();
}

class _RewardWheelCardState extends State<RewardWheelCard> {
  double _turns = 0;
  String? _lastPrize;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(eyebrow: 'Ruleta', title: 'Gira por premios'),
            const SizedBox(height: 18),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _turns),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.rotate(angle: value * math.pi, child: child);
                },
                child: GestureDetector(
                  onTap: _spin,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [_coral, _gold, _olive, _coral],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _coral.withValues(alpha: 0.22),
                          blurRadius: 26,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 126,
                        height: 126,
                        decoration: const BoxDecoration(
                          color: _surface,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GIRAR',
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _lastPrize == null
                  ? 'Toca la ruleta para ganar recompensas.'
                  : 'Último premio: $_lastPrize',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _spin() {
    setState(() {
      _turns += 4 + math.Random().nextDouble() * 3;
      _lastPrize = widget.controller.spinWheel();
    });
  }
}

class MenuItemCard extends StatefulWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onExpanded,
    required this.onCustomizationTap,
    required this.onAddToCart,
  });

  final MenuItemModel item;
  final VoidCallback onExpanded;
  final ValueChanged<String> onCustomizationTap;
  final VoidCallback onAddToCart;

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        item.coverImage,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: GoogleFonts.manrope(
                              color: _muted,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currency(item.price),
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w800,
                              color: _coral,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _coral,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 280),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GalleryCarousel(images: item.galleryImages, height: 210),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InfoBadge(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Calorías',
                            value: item.calories,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoBadge(
                            icon: Icons.schedule_rounded,
                            label: 'Preparación',
                            value: item.prepTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingredientes',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.ingredients.join(', '),
                      style: GoogleFonts.manrope(color: _muted, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Personalización',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.customizations.map((customization) {
                        return ActionChip(
                          onPressed: () =>
                              widget.onCustomizationTap(customization),
                          label: Text(customization),
                          backgroundColor: _surface,
                          side: const BorderSide(color: _line),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: widget.onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Agregar al carrito'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      widget.onExpanded();
    }
  }
}

class RestaurantSocialSection extends StatelessWidget {
  const RestaurantSocialSection({
    super.key,
    required this.restaurant,
    required this.clips,
    required this.posts,
    required this.comments,
    required this.commentController,
    required this.onLikeComment,
    required this.onSubmitComment,
  });

  final Restaurant restaurant;
  final List<SocialClip> clips;
  final List<FoodPost> posts;
  final List<RestaurantComment> comments;
  final TextEditingController commentController;
  final ValueChanged<String> onLikeComment;
  final VoidCallback onSubmitComment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clips.isNotEmpty) ...[
          const SectionTitle(eyebrow: 'Reels', title: 'Reels del restaurante'),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: clips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final clip = clips[index];
                return SocialClipCard(clip: clip, onTap: () {});
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        const SectionTitle(
          eyebrow: 'Posts',
          title: 'Contenido del restaurante',
        ),
        const SizedBox(height: 14),
        if (posts.isEmpty)
          EmptyState(
            icon: Icons.photo_library_outlined,
            title: 'Sin posts todavía',
            message:
                'Aún no hay publicaciones visibles para ${restaurant.name}.',
          )
        else
          ...posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FoodPostCard(post: post, onTap: () {}),
            ),
          ),
        const SizedBox(height: 24),
        const SectionTitle(eyebrow: 'Comentarios', title: 'Qué dice la gente'),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: commentController,
                  minLines: 2,
                  maxLines: 4,
                  style: GoogleFonts.manrope(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: _inputDecoration(
                    'Escribe tu comentario sobre este restaurante',
                    Icons.mode_comment_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onSubmitComment,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Publicar comentario'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (comments.isEmpty)
          const EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Sin comentarios',
            message: 'Sé el primero en dejar una opinión de este restaurante.',
          )
        else
          ...comments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCommentCard(
                comment: comment,
                onLike: () => onLikeComment(comment.id),
              ),
            ),
          ),
      ],
    );
  }
}

class RestaurantCommentCard extends StatelessWidget {
  const RestaurantCommentCard({
    super.key,
    required this.comment,
    required this.onLike,
  });

  final RestaurantComment comment;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _canvas,
                  child: Text(
                    comment.author.substring(0, 1),
                    style: GoogleFonts.sora(
                      color: _coral,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author,
                        style: GoogleFonts.sora(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${comment.handle} · ${comment.timeLabel}',
                        style: GoogleFonts.manrope(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          comment.likedByCurrentUser
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color:
                              comment.likedByCurrentUser ? _coral : _muted,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likesLabel,
                          style: GoogleFonts.manrope(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.message,
              style: GoogleFonts.manrope(
                color: _ink,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.restaurant,
    required this.onOpenMaps,
  });

  final Restaurant restaurant;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                restaurant.contactPhotoAsset,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              restaurant.contactName,
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: _ink,
              ),
            ),
            const SizedBox(height: 12),
            ContactRow(icon: Icons.phone_rounded, text: restaurant.phone),
            const SizedBox(height: 10),
            ContactRow(
              icon: Icons.location_on_rounded,
              text: restaurant.address,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.map_rounded),
              label: const Text('Abrir ubicación en OpenStreetMap'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SocialChip(
                  icon: Icons.camera_alt_rounded,
                  label: restaurant.instagram,
                ),
                SocialChip(
                  icon: Icons.facebook_rounded,
                  label: restaurant.facebook,
                ),
                const SocialChip(icon: Icons.chat_rounded, label: 'WhatsApp'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showCreateSocialSheet(
  BuildContext context,
  AppController controller, {
  required bool reel,
}) async {
  final textController = TextEditingController();
  var selectedRestaurantId = restaurants.first.id;
  var selectedDuration = 30;
  PlatformFile? selectedFile;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _surface,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reel ? 'Crear reel' : 'Crear post',
                  style: GoogleFonts.sora(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedRestaurantId,
                  decoration: _inputDecoration(
                    'Restaurante',
                    Icons.storefront_rounded,
                  ),
                  items: restaurants.map((restaurant) {
                    return DropdownMenuItem<int>(
                      value: restaurant.id,
                      child: Text(restaurant.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setModalState(() {
                      selectedRestaurantId = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: textController,
                  minLines: 2,
                  maxLines: 4,
                  style: GoogleFonts.manrope(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: _inputDecoration(
                    reel ? 'Título del reel' : 'Texto del post',
                    reel
                        ? Icons.play_circle_outline_rounded
                        : Icons.edit_note_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true,
                    );
                    if (result == null || result.files.isEmpty) {
                      return;
                    }
                    setModalState(() {
                      selectedFile = result.files.single;
                    });
                  },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(
                    selectedFile == null
                        ? 'Subir imagen'
                        : 'Imagen: ${selectedFile!.name}',
                  ),
                ),
                if (reel) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Duración del reel',
                    style: GoogleFonts.manrope(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          selected: selectedDuration == 30,
                          label: const Text('30 segundos'),
                          onSelected: (_) {
                            setModalState(() {
                              selectedDuration = 30;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          selected: selectedDuration == 60,
                          label: const Text('60 segundos'),
                          onSelected: (_) {
                            setModalState(() {
                              selectedDuration = 60;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (reel) {
                        controller.createSocialClip(
                          restaurantId: selectedRestaurantId,
                          title: textController.text,
                          durationSeconds: selectedDuration,
                          mediaBytes: selectedFile?.bytes,
                          mediaLabel: selectedFile?.name,
                        );
                      } else {
                        controller.createFoodPost(
                          restaurantId: selectedRestaurantId,
                          caption: textController.text,
                          mediaBytes: selectedFile?.bytes,
                          mediaLabel: selectedFile?.name,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      reel
                          ? Icons.play_circle_fill_rounded
                          : Icons.publish_rounded,
                    ),
                    label: Text(reel ? 'Publicar reel' : 'Publicar post'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  textController.dispose();
}

Future<void> _openMapsForRestaurant(
  BuildContext context,
  Restaurant restaurant,
) async {
  final url = Uri.parse(
    'https://www.openstreetmap.org/?mlat=${restaurant.latitude}&mlon=${restaurant.longitude}#map=17/${restaurant.latitude}/${restaurant.longitude}',
  );
  final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir OpenStreetMap.')),
    );
  }
}

class GalleryCarousel extends StatefulWidget {
  const GalleryCarousel({
    super.key,
    required this.images,
    required this.height,
    this.showArrows = false,
  });

  final List<String> images;
  final double height;
  final bool showArrows;

  @override
  State<GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<GalleryCarousel> {
  late final PageController _controller;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                return Image.asset(widget.images[index], fit: BoxFit.cover);
              },
            ),
          ),
        ),
        if (widget.showArrows && widget.images.length > 1) ...[
          Positioned(
            left: 10,
            child: _CarouselArrow(
              icon: Icons.chevron_left_rounded,
              onTap: () => _move(-1),
            ),
          ),
          Positioned(
            right: 10,
            child: _CarouselArrow(
              icon: Icons.chevron_right_rounded,
              onTap: () => _move(1),
            ),
          ),
        ],
        if (widget.images.length > 1)
          Positioned(
            bottom: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.images.length, (dotIndex) {
                    final active = dotIndex == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _move(int delta) {
    final next = (_index + delta).clamp(0, widget.images.length - 1);
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.34),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

class InfoBadge extends StatelessWidget {
  const InfoBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: _coral),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  const ContactRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _coral),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              color: _ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class SocialChip extends StatelessWidget {
  const SocialChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: _coral, size: 18),
      label: Text(label),
      backgroundColor: _surface,
      side: const BorderSide(color: _line),
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.restaurantName,
                        style: GoogleFonts.manrope(
                          color: _muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                QuantityButton(icon: Icons.remove_rounded, onTap: onDecrease),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    item.quantity.toString(),
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                QuantityButton(icon: Icons.add_rounded, onTap: onIncrease),
                const Spacer(),
                Text(
                  _currency(item.price * item.quantity),
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w800,
                    color: _coral,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  const QuantityButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: _surface,
        foregroundColor: _ink,
      ),
      icon: Icon(icon),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasis
        ? GoogleFonts.sora(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _ink,
          )
        : GoogleFonts.manrope(fontWeight: FontWeight.w700, color: _muted);
    final valueStyle = emphasis
        ? GoogleFonts.sora(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _coral,
          )
        : GoogleFonts.manrope(fontWeight: FontWeight.w800, color: _ink);

    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: achievement.unlocked
              ? const Color(0xFFE5F7EB)
              : _surface,
          foregroundColor: achievement.unlocked
              ? const Color(0xFF2E9B4C)
              : _coral,
          child: Icon(
            achievement.unlocked
                ? Icons.check_rounded
                : Icons.lock_outline_rounded,
          ),
        ),
        title: Text(
          achievement.name,
          style: GoogleFonts.sora(fontWeight: FontWeight.w800, color: _ink),
        ),
        subtitle: Text(
          achievement.description,
          style: GoogleFonts.manrope(color: _muted),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _surface,
              foregroundColor: _coral,
              child: Icon(icon, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final latest = controller.notifications.isEmpty
        ? null
        : controller.notifications.last;
    return Positioned(
      left: 20,
      right: 20,
      bottom: 92,
      child: IgnorePointer(
        ignoring: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: latest == null
              ? const SizedBox.shrink()
              : Material(
                  key: ValueKey(latest.id),
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        latest.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

String _currency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

InputDecoration _inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.manrope(color: _muted),
    prefixIcon: Icon(icon, color: _coral),
    filled: true,
    fillColor: _card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: _coral, width: 1.2),
    ),
  );
}

IconData _paymentMethodIcon(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.card:
      return Icons.credit_card_rounded;
    case PaymentMethodType.cash:
      return Icons.payments_rounded;
    case PaymentMethodType.wallet:
      return Icons.account_balance_wallet_rounded;
    case PaymentMethodType.instant:
      return Icons.bolt_rounded;
    case PaymentMethodType.nequi:
      return Icons.phone_android_rounded;
    case PaymentMethodType.bankTransfer:
      return Icons.account_balance_rounded;
  }
}

String _date(DateTime value) {
  const months = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${value.day} ${months[value.month - 1]} · ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String _paymentMethodLabel(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.card:
      return 'Tarjeta';
    case PaymentMethodType.cash:
      return 'Efectivo';
    case PaymentMethodType.wallet:
      return 'Billetera';
    case PaymentMethodType.instant:
      return 'Transferencia';
    case PaymentMethodType.nequi:
      return 'Nequi';
    case PaymentMethodType.bankTransfer:
      return 'Transferencia bancaria';
  }
}

String _orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.confirmed:
      return 'Confirmado';
    case OrderStatus.preparing:
      return 'Preparando';
    case OrderStatus.onTheWay:
      return 'En camino';
    case OrderStatus.delivered:
      return 'Entregado';
  }
}

Color _orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.confirmed:
      return _coral;
    case OrderStatus.preparing:
      return _gold;
    case OrderStatus.onTheWay:
      return _olive;
    case OrderStatus.delivered:
      return const Color(0xFF2E7D32);
  }
}

Color _orderStatusBackground(OrderStatus status) {
  switch (status) {
    case OrderStatus.confirmed:
      return _coral.withValues(alpha: 0.12);
    case OrderStatus.preparing:
      return _gold.withValues(alpha: 0.18);
    case OrderStatus.onTheWay:
      return _olive.withValues(alpha: 0.14);
    case OrderStatus.delivered:
      return const Color(0xFF2E7D32).withValues(alpha: 0.12);
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _orderStatusBackground(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _orderStatusLabel(status),
        style: GoogleFonts.manrope(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
