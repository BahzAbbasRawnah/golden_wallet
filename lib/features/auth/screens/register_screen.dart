import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';
import 'package:golden_wallet/shared/widgets/custom_messages.dart';
import 'package:image_picker/image_picker.dart';

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _acceptTerms = false;

  File? _identityFrontImage;
  File? _identityBackImage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _identityNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, bool isFrontImage) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFrontImage) {
            _identityFrontImage = File(pickedFile.path);
          } else {
            _identityBackImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        context.showErrorMessage(
          'errorOccurred'.tr(),
          action: CustomSnackBarMessages.createRetryAction(() {
            _pickImage(source, isFrontImage);
          }),
        );
      }
    }
  }

  // Show image picker options
  void _showImagePickerOptions(bool isFrontImage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFrontImage ? 'identityFront'.tr() : 'identityBack'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldDark,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('takePhoto'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isFrontImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('chooseFromGallery'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isFrontImage);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Register user
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check terms acceptance
      if (!_acceptTerms) {
        context.showWarningMessage(
          'acceptTermsError'.tr(),
          action: CustomSnackBarMessages.createDismissAction(() {
            // Dismiss action
          }),
        );
        return;
      }

      // Check identity images
      if (_identityFrontImage == null || _identityBackImage == null) {
        String errorMessage =
            _identityFrontImage == null && _identityBackImage == null
                ? 'bothIdentityImagesRequired'.tr()
                : _identityFrontImage == null
                    ? 'identityFrontRequired'.tr()
                    : 'identityBackRequired'.tr();

        context.showErrorMessage(
          errorMessage,
          action: CustomSnackBarMessages.createAction(
            label: 'uploadNow'.tr(),
            onPressed: () {
              _showImagePickerOptions(_identityFrontImage == null);
            },
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate registration delay
      await Future.delayed(const Duration(seconds: 2));

      // Show success message and navigate to phone verification
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        context.showSuccessMessage(
          'registrationSuccessful'.tr(),
          duration: const Duration(seconds: 2),
        );

        // Navigate after a short delay to allow the user to see the success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _navigateToPhoneVerification();
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Navigate to phone verification
  void _navigateToPhoneVerification() {
    Navigator.pushNamed(
      context,
      AppRoutes.phoneVerification,
      arguments: _emailController.text,
    );
  }

  // Build image picker widget
  Widget _buildImagePicker({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: image != null
                ? AppTheme.primaryColor
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (image != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? 'tapToChange'.tr() : 'uploadImage'.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to login screen
  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  // Title
                  Text(
                    'signUp'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'signUpSubtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    label: 'fullName'.tr(),
                    hint: 'John Doe',
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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

                  // Identity number field
                  CustomTextField(
                    controller: _identityNumberController,
                    label: 'identityNumber'.tr(),
                    hint: 'XXXXXXXXX',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      // Basic identity number validation (adjust as needed)
                      if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value)) {
                        return 'invalidIdentity'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Identity card front image
                  _buildImagePicker(
                    title: 'identityFront'.tr(),
                    image: _identityFrontImage,
                    onTap: () => _showImagePickerOptions(true),
                  ),
                  const SizedBox(height: 16),

                  // Identity card back image
                  _buildImagePicker(
                    title: 'identityBack'.tr(),
                    image: _identityBackImage,
                    onTap: () => _showImagePickerOptions(false),
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
                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'confirmPassword'.tr(),
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    showTogglePasswordButton: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'requiredField'.tr();
                      }
                      if (value != _passwordController.text) {
                        return 'passwordsDontMatch'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms and conditions checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.goldDark,
                      ),
                      Expanded(
                        child: Text(
                          'agreeTerms'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Register button with gold gradient
                  Center(
                    child: CustomButton(
                      text: 'signUp'.tr(),
                      onPressed: _register,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'alreadyHaveAccount'.tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
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
