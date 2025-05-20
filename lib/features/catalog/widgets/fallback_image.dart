import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';

/// Widget for displaying an image with a fallback
class FallbackImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final double? fallbackIconSize;
  final Color? fallbackIconColor;
  final VoidCallback? onTap;
  
  const FallbackImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.fallbackIcon = Icons.image,
    this.fallbackIconSize,
    this.fallbackIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey[200];
    final effectiveFallbackIconColor = fallbackIconColor ?? Colors.grey[400];
    final effectiveFallbackIconSize = fallbackIconSize ?? 24.0;
    
    Widget imageWidget;
    
    if (imageUrl.startsWith('http')) {
      // Network image
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(
            effectiveBackgroundColor,
            effectiveFallbackIconColor,
            effectiveFallbackIconSize,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildLoading(effectiveBackgroundColor);
        },
      );
    } else {
      // Asset image
      try {
        imageWidget = Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(
              effectiveBackgroundColor,
              effectiveFallbackIconColor,
              effectiveFallbackIconSize,
            );
          },
        );
      } catch (e) {
        imageWidget = _buildFallback(
          effectiveBackgroundColor,
          effectiveFallbackIconColor,
          effectiveFallbackIconSize,
        );
      }
    }
    
    final wrappedImage = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: imageWidget,
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: wrappedImage,
      );
    }
    
    return wrappedImage;
  }
  
  /// Build fallback widget
  Widget _buildFallback(
    Color? backgroundColor,
    Color? iconColor,
    double iconSize,
  ) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Center(
        child: Icon(
          fallbackIcon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
  
  /// Build loading widget
  Widget _buildLoading(Color? backgroundColor) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
