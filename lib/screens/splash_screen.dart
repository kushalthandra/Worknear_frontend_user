import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller for logo transition
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Fade controller for other elements
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation - shrinks the logo
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.75, // Shrink to 75% of original size (120 -> 90)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Position animation - moves logo up
    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: const Offset(0, -0.69), // Reduced movement to better match login position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for text and loading indicator
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Background color animation
    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF547DCD),
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeAuth();
  }

  // In lib/screens/splash_screen.dart

Future<void> _initializeAuth() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  _fadeController.forward();

  await Future.delayed(const Duration(milliseconds: 300));
  if (!mounted) return;

  try {
    await _animationController.forward().orCancel;
  } on TickerCanceled {
    return;
  }

  if (!mounted) return;
  await _checkAuthAndNavigate();
}
// Your _checkAuthAndNavigate function is likely fine, but ensure it also has a mounted check.
Future<void> _checkAuthAndNavigate() async {
  if (!mounted) return; // Good practice to have this here too

  final session = Supabase.instance.client.auth.currentSession;

  if (!mounted) return; // Check again after the async call to Supabase

  if (session != null) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _fadeController]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColorAnimation.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo container
                SlideTransition(
                  position: _positionAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          size: 90,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // App name with fade animation
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Work Near',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                // Loading indicator with fade animation
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
