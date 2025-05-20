import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/profile/models/user_model.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';

/// Dialog for editing profile information
class EditProfileDialog extends StatefulWidget {
  final User user;
  final Function(String name, String email, String phoneNumber) onSave;
  
  const EditProfileDialog({
    Key? key,
    required this.user,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  /// Save profile changes
  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Call the onSave callback
      widget.onSave(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              Text(
                'editProfile'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Name field
              CustomTextField(
                controller: _nameController,
                label: 'fullName'.tr(),
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email field
              CustomTextField(
                controller: _emailController,
                label: 'email'.tr(),
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'requiredField'.tr();
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'invalidEmail'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone field
              CustomTextField(
                controller: _phoneController,
                label: 'phoneNumber'.tr(),
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'requiredField'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  CustomButton(
                    text: 'cancel'.tr(),
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.text,
                    isFullWidth: false,
                  ),
                  const SizedBox(width: 16),
                  
                  // Save button
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
                      text: 'saveChanges'.tr(),
                      onPressed: _saveChanges,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for editing address information
class EditAddressDialog extends StatefulWidget {
  final UserAddress? address;
  final Function(String street, String city, String state, String country, String postalCode) onSave;
  
  const EditAddressDialog({
    Key? key,
    this.address,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _countryController = TextEditingController(text: widget.address?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
  }
  
  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
  
  /// Save address changes
  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Call the onSave callback
      widget.onSave(
        _streetController.text,
        _cityController.text,
        _stateController.text,
        _countryController.text,
        _postalCodeController.text,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  'editAddress'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                ),
                const SizedBox(height: 24),
                
                // Street field
                CustomTextField(
                  controller: _streetController,
                  label: 'street'.tr(),
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // City field
                CustomTextField(
                  controller: _cityController,
                  label: 'city'.tr(),
                  prefixIcon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // State field
                CustomTextField(
                  controller: _stateController,
                  label: 'state'.tr(),
                  prefixIcon: Icons.map,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Country field
                CustomTextField(
                  controller: _countryController,
                  label: 'country'.tr(),
                  prefixIcon: Icons.public,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Postal code field
                CustomTextField(
                  controller: _postalCodeController,
                  label: 'postalCode'.tr(),
                  prefixIcon: Icons.markunread_mailbox,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'requiredField'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    CustomButton(
                      text: 'cancel'.tr(),
                      onPressed: () => Navigator.pop(context),
                      type: ButtonType.text,
                      isFullWidth: false,
                    ),
                    const SizedBox(width: 16),
                    
                    // Save button
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
                        text: 'saveChanges'.tr(),
                        onPressed: _saveChanges,
                        isLoading: _isLoading,
                        type: ButtonType.primary,
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        isFullWidth: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
