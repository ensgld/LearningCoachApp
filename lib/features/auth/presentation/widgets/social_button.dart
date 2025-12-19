import 'package:flutter/material.dart';

/// Social Button Widget
///
/// Google ve Apple ile giriş butonları için kullanılır.
/// Tam genişlik, outline stil, icon + text içerir.
///
/// Mock implementasyon - gerçekte OAuth provider'ları kullanılır:
/// - Google: google_sign_in paketi
/// - Apple: sign_in_with_apple paketi
class SocialButton extends StatelessWidget {
  /// Buton ikonu (Google, Apple vb.)
  final IconData icon;

  /// Buton metni
  final String label;

  /// Tıklama callback'i
  final VoidCallback onPressed;

  /// Buton rengi (opsiyonel, varsayılan white)
  final Color? backgroundColor;

  /// Icon rengi (opsiyonel)
  final Color? iconColor;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Material 3 standart yükseklik
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.onSurface,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
