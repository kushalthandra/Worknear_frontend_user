import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _sessionReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Wait a moment for URL to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if we have a valid session (Supabase should handle URL automatically)
      final session = Supabase.instance.client.auth.currentSession;
      
      print('Current session: ${session?.user.email}');
      
      if (session?.user != null) {
        print('Session found - ready for password reset');
        setState(() => _sessionReady = true);
      } else {
        print('No session - checking URL manually');
        await _handleUrlDirectly();
      }
    } catch (e) {
      print('Session check error: $e');
      setState(() {
        _errorMessage = 'Reset link may have expired. Please request a new one.';
      });
    }
  }

  Future<void> _handleUrlDirectly() async {
    try {
      // Get the current URL
      final currentUrl = Uri.base.toString();
      print('Current URL: $currentUrl');
      
      // Let Supabase handle the URL automatically
      if (currentUrl.contains('access_token') && currentUrl.contains('type=recovery')) {
        // Supabase should automatically process this URL
        await Future.delayed(const Duration(milliseconds: 1000));
        
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.user != null) {
          setState(() => _sessionReady = true);
        } else {
          throw Exception('Could not establish session from URL');
        }
      } else {
        throw Exception('Invalid reset URL format');
      }
    } catch (e) {
      print('URL handling error: $e');
      setState(() {
        _errorMessage = 'Invalid reset link. Please request a new one.';
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Password updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Sign out and redirect
        await Supabase.instance.client.auth.signOut();
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } else {
        throw Exception('Password update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color(0xFF547DCD),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }
    
    if (!_sessionReady) {
      return _buildLoadingView();
    }
    
    return _buildPasswordForm();
  }

  Widget _buildLoadingView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFF547DCD)),
        SizedBox(height: 16),
        Text('Processing reset link...'),
        SizedBox(height: 8),
        Text(
          'This may take a few seconds',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red,
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Reset Link Issue',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          _errorMessage!,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            children: [
              Text(
                '💡 Try This:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Request a new reset link\n'
                '2. Click the link immediately when it arrives\n'
                '3. Make sure you\'re using the latest email',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF547DCD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/forgot-password',
                (route) => false,
              );
            },
            child: const Text(
              'Get New Reset Link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(color: Color(0xFF547DCD)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Reset Link Valid!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF547DCD),
          ),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Enter your new password below',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),

        Form(
          key: _formKey,
          child: Column(
            children: [
              // New Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF547DCD)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF547DCD)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Update Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF547DCD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}