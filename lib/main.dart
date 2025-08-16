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
import 'dart:html' as html;

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
        // Customize app bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF547DCD),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        // Customize button theme
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
        // Customize card theme
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Customize input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        // Tab Bar Theme
        tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF547DCD),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF547DCD),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
        // Bottom Navigation Bar Theme
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
        // Handle parameterized routes
        switch (settings.name) {
          case '/service-details':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (_) => ServiceDetailsScreen(
                  serviceName: args['serviceName'],
                  serviceIcon: args['serviceIcon'],
                  serviceColor: args['serviceColor'],
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
            return null; // Let the routes below handle it
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
    // Small delay to ensure everything is initialized
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    try {
      // Get current URL
      final currentUrl = html.window.location.href;
      final uri = Uri.parse(currentUrl);
      
      print('=== AUTH HANDLER DEBUG ===');
      print('Current URL: $currentUrl');
      print('Fragment: ${uri.fragment}');
      print('Path: ${uri.path}');
      print('=========================');
      
      // Check if this is a password reset link
      bool isPasswordReset = false;
      
      // Check fragment for reset indicators
      if (uri.fragment.contains('type=recovery') || 
          uri.fragment.contains('access_token=') ||
          uri.path.contains('reset-password')) {
        isPasswordReset = true;
      }
      
      // Also check query parameters
      if (uri.queryParameters.containsKey('type') && 
          uri.queryParameters['type'] == 'recovery') {
        isPasswordReset = true;
      }
      
      if (isPasswordReset) {
        print('🔐 Password reset detected - navigating to reset screen');
        Navigator.of(context).pushReplacementNamed('/reset-password');
        return;
      }
      
      // Check normal authentication status
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        print('✅ User authenticated - navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('❌ No session - navigating to login');
        Navigator.of(context).pushReplacementNamed('/login');
      }
      
    } catch (e) {
      print('❌ Auth handler error: $e');
      // Fallback to login on any error
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while determining route
    return const SplashScreen();
  }
}

// Navigation Helper Class
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