import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/utils/language_util.dart';
import 'dart:ui' as ui;
/// Translation keys for SnackBar messages
class SnackBarTranslationKeys {
  static String success = 'snackbar.success';
  static String error = 'snackbar.error';
  static String warning = 'snackbar.warning';
  static String info = 'snackbar.info';
  static String loading = 'snackbar.loading';
  static String retry = 'snackbar.retry';
  static String undo = 'snackbar.undo';
  static String dismiss = 'snackbar.dismiss';
  static String close = 'snackbar.close';
  static String tryAgain = 'snackbar.tryAgain';
  static String operationSuccess = 'snackbar.operationSuccess';
  static String operationFailed = 'snackbar.operationFailed';
  static String networkError = 'snackbar.networkError';
  static String dataLoadError = 'snackbar.dataLoadError';
  static String dataSaveError = 'snackbar.dataSaveError';
  static String invalidInput = 'snackbar.invalidInput';
  static String processingRequest = 'snackbar.processingRequest';
}

class CustomSnackBarMessages {
  /// Shows a success message with a green background and check icon
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [duration]: How long to display the message (defaults to 3 seconds)
  /// - [action]: Optional action button for the SnackBar
  static SnackBar success({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return _createSnackBar(
      message: message,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error/failure message with a red background and error icon
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [duration]: How long to display the message (defaults to 4 seconds)
  /// - [action]: Optional action button for the SnackBar
  static SnackBar error({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return _createSnackBar(
      message: message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning message with an amber/orange background and warning icon
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [duration]: How long to display the message (defaults to 4 seconds)
  /// - [action]: Optional action button for the SnackBar
  static SnackBar warning({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return _createSnackBar(
      message: message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning_amber_outlined,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info message with a blue background and info icon
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [duration]: How long to display the message (defaults to 3 seconds)
  /// - [action]: Optional action button for the SnackBar
  static SnackBar info({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return _createSnackBar(
      message: message,
      backgroundColor: AppTheme.infoColor,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Shows a loading message with an optional progress indicator
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [showProgress]: Whether to show a circular progress indicator
  /// - [duration]: How long to display the message (defaults to 10 seconds)
  /// - [action]: Optional action button for the SnackBar
  static SnackBar loading({
    required String message,
    bool showProgress = true,
    Duration duration = const Duration(seconds: 10),
    SnackBarAction? action,
  }) {
    return _createSnackBar(
      message: message,
      backgroundColor: AppTheme.primaryDarkColor,
      icon: showProgress ? null : Icons.hourglass_top_outlined,
      duration: duration,
      action: action,
      showProgress: showProgress,
    );
  }

  /// Helper method to show a SnackBar with the given context
  ///
  /// Parameters:
  /// - [context]: The BuildContext to show the SnackBar in
  /// - [snackBar]: The SnackBar to show
  static void show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Helper method to create a SnackBar with consistent styling
  ///
  /// Parameters:
  /// - [message]: The message text to display
  /// - [backgroundColor]: The background color of the SnackBar
  /// - [icon]: The icon to display next to the message
  /// - [duration]: How long to display the message
  /// - [action]: Optional action button for the SnackBar
  /// - [showProgress]: Whether to show a circular progress indicator
  static SnackBar _createSnackBar({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    required Duration duration,
    SnackBarAction? action,
    bool showProgress = false,
  }) {
    return SnackBar(
      content: Builder(
        builder: (context) {
          final isRtl = LanguageUtil.isRtl(context);

          return Row(
            textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            children: [
              // Show either progress indicator or icon
              if (showProgress) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 16),
              ],

              // Message text
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          );
        },
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 4,
      action: action,
    );
  }

  /// Creates a SnackBarAction with gold-themed styling
  ///
  /// Parameters:
  /// - [label]: The text to display on the action button (can be a translation key)
  /// - [onPressed]: The callback to invoke when the action is pressed
  /// - [useTranslation]: Whether to translate the label (default: true)
  static SnackBarAction createAction({
    required String label,
    required VoidCallback onPressed,
    bool useTranslation = true,
  }) {
    return SnackBarAction(
      label: useTranslation ? label.tr() : label,
      textColor: AppTheme.goldLight,
      onPressed: onPressed,
    );
  }

  /// Creates a retry action with localized text
  static SnackBarAction createRetryAction(VoidCallback onPressed) {
    return createAction(
      label: SnackBarTranslationKeys.retry,
      onPressed: onPressed,
    );
  }

  /// Creates an undo action with localized text
  static SnackBarAction createUndoAction(VoidCallback onPressed) {
    return createAction(
      label: SnackBarTranslationKeys.undo,
      onPressed: onPressed,
    );
  }

  /// Creates a dismiss action with localized text
  static SnackBarAction createDismissAction(VoidCallback onPressed) {
    return createAction(
      label: SnackBarTranslationKeys.dismiss,
      onPressed: onPressed,
    );
  }
}

/// Extension methods for easier usage of CustomSnackBarMessages
extension CustomSnackBarMessagesExtension on BuildContext {
  /// Shows a success message in this context
  void showSuccessMessage(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    CustomSnackBarMessages.show(
      this,
      CustomSnackBarMessages.success(
        message: message,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an error message in this context
  void showErrorMessage(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    CustomSnackBarMessages.show(
      this,
      CustomSnackBarMessages.error(
        message: message,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows a warning message in this context
  void showWarningMessage(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    CustomSnackBarMessages.show(
      this,
      CustomSnackBarMessages.warning(
        message: message,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an info message in this context
  void showInfoMessage(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    CustomSnackBarMessages.show(
      this,
      CustomSnackBarMessages.info(
        message: message,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows a loading message in this context
  void showLoadingMessage(
    String message, {
    bool showProgress = true,
    Duration duration = const Duration(seconds: 10),
    SnackBarAction? action,
  }) {
    CustomSnackBarMessages.show(
      this,
      CustomSnackBarMessages.loading(
        message: message,
        showProgress: showProgress,
        duration: duration,
        action: action,
      ),
    );
  }
}
