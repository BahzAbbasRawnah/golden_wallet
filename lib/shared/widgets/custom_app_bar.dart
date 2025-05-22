import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';

/// Custom app bar widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.goldDark,
        ),
       
      ),
      centerTitle: false,
      elevation: elevation,
      backgroundColor: Colors.transparent,
      foregroundColor:
          foregroundColor ?? (isDarkMode ? Colors.white : Colors.black),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.goldDark,
                ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}
