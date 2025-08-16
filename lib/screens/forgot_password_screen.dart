import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Use the exact URL format that Supabase expects
        final redirectUrl = 'http://localhost:8080/#/reset-password';
        
        print('Sending reset email to: ${_emailController.text.trim()}');
        print('Redirect URL: $redirectUrl');
        
        await Supabase.instance.client.auth.resetPasswordForEmail(
          _emailController.text.trim(),
          redirectTo: redirectUrl,
        );

        setState(() => _emailSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        print('Reset password error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_reset,
          size: 80,
          color: Color(0xFF547DCD),
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Forgot Your Password?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF547DCD),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Enter your email and we\'ll send you a reset link',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF547DCD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
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
                  onPressed: _isLoading ? null : _sendPasswordReset,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Reset Email',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back to Login',
            style: TextStyle(color: Color(0xFF547DCD)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF547DCD),
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Reset link sent to:\n${_emailController.text}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                '📧 Important Steps:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 8),
              Text(
                '1. Check your email inbox\n'
                '2. Click the "Reset My Password" button\n'
                '3. The link will open in your browser\n'
                '4. Enter your new password\n'
                '5. Return to the app to login',
                style: TextStyle(fontSize: 14, color: Colors.blue),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Column(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                '⏰ Link expires in 60 minutes',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                'For security, reset links expire quickly.\nIf expired, request a new one.',
                style: TextStyle(fontSize: 14, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _emailSent = false);
                  _sendPasswordReset();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF547DCD),
                  side: const BorderSide(color: Color(0xFF547DCD)),
                ),
                child: const Text('Send New Link'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF547DCD),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}