import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Get Supabase credentials from environment
  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_KEY'];

  // Check for missing credentials
  if (url == null || key == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_KEY in .env');
  }

  // Initialize Supabase before running the app
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
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
