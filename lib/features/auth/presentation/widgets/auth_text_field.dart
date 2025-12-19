import 'package:flutter/material.dart';

/// Auth Text Field Widget
///
/// Kimlik doğrulama ekranları için özelleştirilmiş TextField.
/// Email, şifre ve diğer form alanları için kullanılır.
///
/// Özellikler:
/// - Material 3 tasarım
/// - Validasyon desteği
/// - Prefix/suffix icon
/// - Şifre göster/gizle (obscureText için)
/// - Keyboard type desteği
class AuthTextField extends StatefulWidget {
  /// Label metni (üstte görünür)
  final String label;

  /// Placeholder metni
  final String? hint;

  /// Controller (form state yönetimi için)
  final TextEditingController? controller;

  /// Başlangıç prefix icon
  final IconData? prefixIcon;

  /// Şifre alanı mı? (göster/gizle icon ekler)
  final bool isPassword;

  /// Klavye tipi (email, text, number vb.)
  final TextInputType keyboardType;

  /// Keyboard action (next, done vb.)
  final TextInputAction textInputAction;

  /// Validasyon fonksiyonu
  final String? Function(String?)? validator;

  /// onChanged callback
  final void Function(String)? onChanged;

  /// onSubmitted callback (done'a basınca)
  final void Function(String)? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Şifre görünürlük durumu
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Başlangıçta şifre gizli
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        // Prefix icon (email, lock vb.)
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,

        // Suffix icon (şifre göster/gizle)
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        // Material 3 border stilleri
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
