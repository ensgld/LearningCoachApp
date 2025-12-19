/// Auth Form Validators
///
/// UI seviyesinde form validasyonu için yardımcı fonksiyonlar.
/// Backend validasyonu bu dosyada yok, sadece temel kontroller.
class AuthValidators {
  /// Email Validator
  ///
  /// Kullanım:
  /// ```dart
  /// TextFormField(
  ///   validator: AuthValidators.emailValidator,
  /// )
  /// ```
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }

    // Basit email regex pattern
    // Gerçek uygulamada daha kapsamlı validasyon yapılabilir
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }

    return null; // Validasyon başarılı
  }

  /// Password Validator
  ///
  /// Minimum 8 karakter kontrolü yapar.
  /// Gerçek uygulamada: büyük/küçük harf, rakam, özel karakter kontrolü eklenebilir.
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }

    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalı';
    }

    return null; // Validasyon başarılı
  }

  /// Confirm Password Validator
  ///
  /// İki şifrenin eşleşip eşleşmediğini kontrol eder.
  ///
  /// Kullanım:
  /// ```dart
  /// TextFormField(
  ///   validator: (value) => AuthValidators.confirmPasswordValidator(
  ///     value,
  ///     _passwordController.text,
  ///   ),
  /// )
  /// ```
  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null; // Validasyon başarılı
  }

  /// Display Name Validator
  ///
  /// Kullanıcı adı validasyonu (opsiyonel alan için).
  /// En az 2 karakter kontrolü yapar.
  static String? displayNameValidator(String? value) {
    // Opsiyonel alan - boş olabilir
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }

    return null; // Validasyon başarılı
  }

  /// Required Field Validator
  ///
  /// Genel amaçlı "zorunlu alan" validatörü.
  /// Checkbox'lar için kullanılabilir.
  static String? requiredValidator(bool? value, String fieldName) {
    if (value == null || !value) {
      return '$fieldName kabul edilmelidir';
    }

    return null;
  }
}
