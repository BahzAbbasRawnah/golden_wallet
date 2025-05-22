import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_messages.dart';

/// Example screen to demonstrate the usage of CustomSnackBarMessages
class CustomMessagesExample extends StatelessWidget {
  const CustomMessagesExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('customMessagesExample'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success message example
            _buildExampleButton(
              context: context,
              title: 'Success Message',
              onPressed: () {
                // Using the extension method
                context.showSuccessMessage(
                  SnackBarTranslationKeys.operationSuccess.tr(),
                  action: CustomSnackBarMessages.createUndoAction(() {
                    // Handle undo action
                  }),
                );
              },
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),

            // Error message example
            _buildExampleButton(
              context: context,
              title: 'Error Message',
              onPressed: () {
                // Using the extension method
                context.showErrorMessage(
                  SnackBarTranslationKeys.operationFailed.tr(),
                  action: CustomSnackBarMessages.createRetryAction(() {
                    // Handle retry action
                  }),
                );
              },
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),

            // Warning message example
            _buildExampleButton(
              context: context,
              title: 'Warning Message',
              onPressed: () {
                // Using the extension method with custom message
                context.showWarningMessage(
                  'Your account balance is low.'.tr(),
                  action: CustomSnackBarMessages.createAction(
                    label: 'Top Up',
                    onPressed: () {
                      // Handle top up action
                    },
                  ),
                );
              },
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 16),

            // Info message example
            _buildExampleButton(
              context: context,
              title: 'Info Message',
              onPressed: () {
                // Using the extension method
                context.showInfoMessage(
                  'Gold prices have been updated.',
                );
              },
              color: AppTheme.infoColor,
            ),
            const SizedBox(height: 16),

            // Loading message with progress example
            _buildExampleButton(
              context: context,
              title: 'Loading Message (with progress)',
              onPressed: () {
                // Using the extension method
                context.showLoadingMessage(
                  'Processing your transaction...',
                  showProgress: true,
                );
              },
              color: AppTheme.primaryDarkColor,
            ),
            const SizedBox(height: 16),

            // Loading message without progress example
            _buildExampleButton(
              context: context,
              title: 'Loading Message (without progress)',
              onPressed: () {
                // Using the extension method
                context.showLoadingMessage(
                  'Preparing your data...',
                  showProgress: false,
                );
              },
              color: AppTheme.primaryDarkColor,
            ),
            const SizedBox(height: 16),

            // Using the static methods directly
            _buildExampleButton(
              context: context,
              title: 'Using Static Methods',
              onPressed: () {
                // Using the static method directly
                CustomSnackBarMessages.show(
                  context,
                  CustomSnackBarMessages.success(
                    message: 'This is a success message using static methods!',
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              color: AppTheme.goldDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build example buttons
  Widget _buildExampleButton({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return CustomButton(
      text: title,
      onPressed: onPressed,
      backgroundColor: color,
      textColor: Colors.white,
      height: 50,
    );
  }
}
