import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/order_service.dart';
import 'data/repositories/order_repository.dart';
import 'data/services/address_service.dart';
import 'data/repositories/address_repository.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/home/view_models/order_view_model.dart';
import 'ui/features/profile/view_models/profile_view_model.dart';
import 'ui/features/home/views/home_view.dart';
import 'ui/features/onboarding/views/onboarding_view.dart';

import 'ui/features/auth/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final authRepository = AuthRepository(authService: authService);

  final orderService = OrderService();
  final orderRepository = OrderRepository(orderService: orderService);

  final addressService = AddressService();
  final addressRepository = AddressRepository(addressService: addressService);

  // Initialize stored session locally
  await authRepository.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<OrderService>.value(value: orderService),
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<AddressService>.value(value: addressService),
        Provider<AddressRepository>.value(value: addressRepository),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            authRepository: authRepository,
            orderRepository: orderRepository,
          ),
        ),
        ChangeNotifierProvider<OrderViewModel>(
          create: (_) => OrderViewModel(
            authRepository: authRepository,
            addressRepository: addressRepository,
            orderRepository: orderRepository,
          ),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(authRepository: authRepository),
        ),
      ],
      child: const CustomerApp(),
    ),
  );
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);

    return MaterialApp(
      title: 'myLaundry Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0007B0),
          primary: const Color(0xFF0007B0),
          secondary: const Color(0xFF0B1739),
          surface: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: authRepository.isAuthenticated ? const HomeContainer() : const OnboardingView(),
      routes: {
        '/login': (context) => const LoginView(),
      },
    );
  }
}
