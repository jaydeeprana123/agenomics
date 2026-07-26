class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Enter a valid mobile number';
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 4) return 'Enter a valid pincode';
    return null;
  }

  static String? emiratesId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Emirates ID is required';
    }
    final trimmed = value.trim();
    // UAE Emirates ID format: 784-YYYY-NNNNNNN-N
    final regex = RegExp(r'^784-\d{4}-\d{7}-\d$');
    if (!regex.hasMatch(trimmed)) {
      return 'Enter a valid Emirates ID (e.g. 784-2015-1234567-8)';
    }
    return null;
  }
}
