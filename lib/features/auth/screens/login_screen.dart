import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';
import 'package:local_auth/local_auth.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
      });
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
      });
    }
  }

  // Authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        _navigateToDashboard();
      }
    } catch (e) {
      // Handle authentication error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Login with phone and password
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login delay
      await Future.delayed(const Duration(seconds: 2));

      // Navigate directly to dashboard
      _navigateToDashboard();

      setState(() {
        _isLoading = false;
      });
    }
  }

  // This method was previously used but is now kept for reference
  // void _navigateToPhoneVerification() {
  //   Navigator.pushNamed(
  //     context,
  //     AppRoutes.phoneVerification,
  //     arguments: _emailController.text,
  //   );
  // }

  // Navigate to dashboard
  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  // Navigate to registration screen
  void _navigateToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  // Navigate to forgot password screen
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.05),

                  // App logo
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(100),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),

                  // Welcome text
                  Text(
                    'login'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'appDescription'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Phone field
                  CustomTextField(
                    controller: _emailController,
                    label: 'phone'.tr(),
                    hint: '+971 XX XXX XXXX',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (!RegExp(r'^\+?[0-9]{10,15}$')
                          .hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
                        return 'invalidPhone'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'password'.tr(),
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    showTogglePasswordButton: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (value.length < AppConstants.passwordMinLength) {
                        return 'passwordTooShort'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: Text(
                        'forgotPassword'.tr(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button with gold gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(70),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      text: 'signIn'.tr(),
                      onPressed: _login,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Biometric authentication button
                  if (_canCheckBiometrics)
                    CustomButton(
                      text: 'login'.tr(),
                      icon: Icons.fingerprint,
                      onPressed: _authenticateWithBiometrics,
                      type: ButtonType.secondary,
                    ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 32),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'dontHaveAccount'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: Text(
                            'signUp'.tr(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
