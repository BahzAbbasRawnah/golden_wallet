import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';
import 'package:golden_wallet/shared/widgets/custom_messages.dart';

/// Forgot password screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Send password reset code to phone
  Future<void> _sendResetCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _resetSent = true;
        });

        // Show success message
        context.showSuccessMessage(
          'resetCodeSent'.tr(),
          duration: const Duration(seconds: 2),
        );

        // Navigate after a short delay to allow the user to see the success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.phoneVerification,
              arguments: _phoneController.text,
            );
          }
        });
      }
    }
  }

  // Navigate back to login
  void _navigateToLogin() {
    Navigator.pop(context);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(70),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Title
                  Text(
                    'forgotPassword'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'forgotPasswordSubtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.secondaryLightGrey
                              : AppTheme.secondaryGrey,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 32),

                  if (!_resetSent) ...[
                    // Phone field
                    CustomTextField(
                      controller: _phoneController,
                      label: 'phone'.tr(),
                      hint: '+971 XX XXX XXXX',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'requiredField'.tr();
                        }
                        // Basic phone validation - can be enhanced based on your requirements
                        if (value.replaceAll(RegExp(r'[^0-9]'), '').length <
                            9) {
                          return 'invalidPhone'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Reset password button with gold gradient
                    Center(
                      child: CustomButton(
                        text: 'sendResetCode'.tr(),
                        onPressed: _sendResetCode,
                        isLoading: _isLoading,
                        type: ButtonType.primary,
                      ),
                    ),
                  ] else ...[
                    // Success message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'resetCodeSent'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'checkPhoneInstructions'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _phoneController.text,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Back to login button
                    CustomButton(
                      text: 'backToLogin'.tr(),
                      onPressed: _navigateToLogin,
                      type: ButtonType.secondary,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Back to login link
                  if (!_resetSent)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'rememberPassword'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.secondaryLightGrey
                                  : AppTheme.secondaryGrey,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToLogin,
                            child: Text(
                              'signIn'.tr(),
                              style: TextStyle(
                                color: AppTheme.goldDark,
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
