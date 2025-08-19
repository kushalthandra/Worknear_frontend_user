import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/home.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/search_screen.dart';
import 'screens/my_bookings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_KEY'];

  if (url == null || key == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_KEY in .env');
  }

  await Supabase.initialize(
    url: url,
    anonKey: key,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkNear',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF547DCD),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF547DCD),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF547DCD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFF547DCD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF547DCD),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF547DCD),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/service-details':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => ServiceDetailsScreen(
                  serviceName: args['serviceName'],
                  serviceIcon: args['serviceIcon'],
                  serviceColor: args['serviceColor'],
                  userLocation: args['userLocation'],
                ),
              );
            }
            return _errorRoute();

          case '/booking':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => BookingScreen(
                  serviceName: args['serviceName'],
                  providerName: args['providerName'],
                  providerImage: args['providerImage'],
                  rating: args['rating'],
                  price: args['price'],
                  serviceColor: args['serviceColor'],
                ),
              );
            }
            return _errorRoute();

          default:
            return null;
        }
      },
      routes: {
        '/': (context) => const AuthHandler(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/search': (context) => const SearchScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  @override
  void initState() {
    super.initState();
    _handleInitialRoute();
  }

  Future<void> _handleInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      // For web only: safely get URL if needed. Otherwise skip.
      // Avoid direct import/use of dart:html to prevent build errors.

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class AppNavigator {
  static void navigateToServiceDetails(
    BuildContext context, {
    required String serviceName,
    required IconData serviceIcon,
    required Color serviceColor,
  }) {
    Navigator.pushNamed(
      context,
      '/service-details',
      arguments: {
        'serviceName': serviceName,
        'serviceIcon': serviceIcon,
        'serviceColor': serviceColor,
      },
    );
  }

  static void navigateToBooking(
    BuildContext context, {
    required String serviceName,
    required String providerName,
    required String providerImage,
    required double rating,
    required String price,
    required Color serviceColor,
  }) {
    Navigator.pushNamed(
      context,
      '/booking',
      arguments: {
        'serviceName': serviceName,
        'providerName': providerName,
        'providerImage': providerImage,
        'rating': rating,
        'price': price,
        'serviceColor': serviceColor,
      },
    );
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, '/search');
  }

  static void navigateToBookings(BuildContext context) {
    Navigator.pushNamed(context, '/my-bookings');
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }
}
