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
      begin: const Offset(0, 0),
      end: const Offset(0, -0.69), // Reduced movement to better match login position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for text and loading indicator
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 0.0,
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

  Future<void> _initializeAuth() async {
    // Wait for initial splash display
    await Future.delayed(const Duration(seconds: 2));
    
    // Start fade out animation for text and loading
    _fadeController.forward();
    
    // Wait a bit then start the main transition
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Start the main animation
    _animationController.forward();
    
    // Wait for animation to complete
    await _animationController.forward();
    
    // Check authentication and navigate
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    
    if (session != null) {
      // User is authenticated, navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Navigate to login with instant replacement
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