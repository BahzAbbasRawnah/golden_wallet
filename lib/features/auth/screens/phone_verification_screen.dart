import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Phone verification screen
class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    // Cancel timer first to prevent callbacks after widget is disposed
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _otpController.dispose();
    super.dispose();
  }

  // Start resend timer
  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        // Check if widget is still mounted before updating state
        if (mounted) {
          setState(() {
            _resendTimer--;
          });
        } else {
          // If widget is no longer mounted, cancel the timer
          timer.cancel();
          _timer = null;
        }
      } else {
        timer.cancel();
        _timer = null;
      }
    });
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'invalidCode'.tr(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if widget is still mounted before proceeding
    if (mounted) {
      // Navigate to dashboard
      _navigateToDashboard();

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Resend OTP
  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    // Simulate resend delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if widget is still mounted before showing snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'codeResent'.tr(),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      setState(() {
        _isResending = false;
      });

      _startResendTimer();
    }
  }

  // Navigate to dashboard
  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppTheme.goldDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 32),

                // Title
                Text(
                  'verificationCode'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'enterVerificationCode'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // OTP input
                PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 45,
                      activeFillColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                      inactiveFillColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey[100],
                      selectedFillColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : Colors.white,
                      activeColor: AppTheme.goldColor,
                      inactiveColor: Colors.grey[400],
                      selectedColor: AppTheme.primaryColor,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    onCompleted: (v) {
                      // Auto verify when complete
                      _verifyOtp();
                    },
                    beforeTextPaste: (text) {
                      // Allow only numbers
                      return text?.replaceAll(RegExp(r'[^0-9]'), '') != null;
                    },
                  ),
                
                const SizedBox(height: 32),

                // Verify button
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
                    text: 'verify'.tr(),
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                    type: ButtonType.primary,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Resend code
                Center(
                  child: Column(
                    children: [
                      Text(
                        'didntReceiveCode'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _resendTimer > 0 ? null : _resendOtp,
                        child: _isResending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.goldDark,
                                  ),
                                ),
                              )
                            : Text(
                                _resendTimer > 0
                                    ? '${'resendCode'.tr()} (${_resendTimer}s)'
                                    : 'resendCode'.tr(),
                                style: TextStyle(
                                  color: _resendTimer > 0
                                      ? Colors.grey[500]
                                      : AppTheme.goldDark,
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
    );
  }
}
