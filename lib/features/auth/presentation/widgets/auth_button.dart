import 'package:flutter/material.dart';

/// Auth Button Widget
///
/// Kimlik doğrulama ekranlarında primary aksiyon butonu.
/// "Giriş Yap", "Kayıt Ol" gibi ana butonlar için kullanılır.
///
/// Özellikler:
/// - Loading state (CircularProgressIndicator)
/// - Disabled state
/// - Tam genişlik
/// - Material 3 tasarım
class AuthButton extends StatelessWidget {
  /// Buton metni
  final String label;

  /// Tıklama callback'i
  final VoidCallback? onPressed;

  /// Loading durumu (true ise buton disabled ve loading gösterir)
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Material 3 standart yükseklik
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
