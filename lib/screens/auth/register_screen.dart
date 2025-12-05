import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shield,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join us to protect yourself from scams',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Name Field
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Email Field
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                ),

                const SizedBox(height: 16),

                // Phone Field
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: CustomTextField(
                    controller: _phoneController,
                    label: 'Phone (Optional)',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
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
                ),

                const SizedBox(height: 32),

                // Register Button
                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: CustomButton(
                    text: 'Create Account',
                    onPressed: authState.isLoading ? null : _register,
                    isLoading: authState.isLoading,
                    icon: Icons.person_add,
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                FadeInUp(
                  duration: const Duration(milliseconds: 1300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

