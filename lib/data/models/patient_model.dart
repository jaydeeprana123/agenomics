/// Address object nested under PatientCreate / PatientResponse / PatientUpdate.
class PatientAddress {
  final String? line;
  final String? city;
  final String? state;
  final String? pincode;

  const PatientAddress({
    this.line,
    this.city,
    this.state,
    this.pincode,
  });

  bool get isEmpty =>
      (line == null || line!.trim().isEmpty) &&
      (city == null || city!.trim().isEmpty) &&
      (state == null || state!.trim().isEmpty) &&
      (pincode == null || pincode!.trim().isEmpty);

  factory PatientAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PatientAddress();
    return PatientAddress(
      line: _stringOf(json, const ['line', 'street', 'address_line', 'address']),
      city: _stringOf(json, const ['city']),
      state: _stringOf(json, const ['state', 'emirate']),
      pincode: _stringOf(json, const ['pincode', 'postal_code', 'zip']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (line != null && line!.trim().isNotEmpty) map['line'] = line!.trim();
    if (city != null && city!.trim().isNotEmpty) map['city'] = city!.trim();
    if (state != null && state!.trim().isNotEmpty) map['state'] = state!.trim();
    if (pincode != null && pincode!.trim().isNotEmpty) {
      map['pincode'] = pincode!.trim();
    }
    return map;
  }

  static String? _stringOf(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}

/// Matches Swagger `PatientResponse`.
class PatientModel {
  final String id;
  final String uhid;
  final String hospitalId;
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String gender;
  final String mobile;
  final String? email;
  final PatientAddress? address;
  final String? emiratesId;
  final String source;
  final bool isActive;

  const PatientModel({
    required this.id,
    required this.uhid,
    required this.hospitalId,
    required this.firstName,
    required this.lastName,
    this.dob,
    required this.gender,
    required this.mobile,
    this.email,
    this.address,
    this.emiratesId,
    this.source = 'manual',
    this.isActive = true,
  });

  String get name => '$firstName $lastName'.trim();

  String get patientId => uhid;

  int? get age {
    if (dob == null) return null;
    final now = DateTime.now();
    var value = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      value--;
    }
    return value < 0 ? 0 : value;
  }

  String? get city => address?.city;
  String? get state => address?.state;
  String? get pincode => address?.pincode;
  String? get addressLine => address?.line;

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? addressMap;
    final rawAddress = json['address'];
    if (rawAddress is Map) {
      addressMap = Map<String, dynamic>.from(rawAddress);
    }

    return PatientModel(
      id: json['id']?.toString() ?? '',
      uhid: json['uhid']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null,
      gender: json['gender']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString(),
      address: PatientAddress.fromJson(addressMap),
      emiratesId: json['emirates_id']?.toString(),
      source: json['source']?.toString() ?? 'manual',
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uhid': uhid,
        'hospital_id': hospitalId,
        'first_name': firstName,
        'last_name': lastName,
        'dob': _formatDate(dob),
        'gender': gender,
        'mobile': mobile,
        'email': email,
        'address': address?.toJson(),
        'emirates_id': emiratesId,
        'source': source,
        'is_active': isActive,
      };

  /// Swagger `PatientCreate` body.
  Map<String, dynamic> toCreateJson() {
    final body = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'dob': _formatDate(dob),
      'gender': gender,
      'mobile': mobile.trim(),
      'source': source.trim().isEmpty ? 'manual' : source.trim(),
    };

    final emailValue = email?.trim();
    if (emailValue != null && emailValue.isNotEmpty) {
      body['email'] = emailValue;
    } else {
      body['email'] = null;
    }

    final emirates = emiratesId?.trim();
    if (emirates == null || emirates.isEmpty) {
      throw ArgumentError('Emirates ID is required for patient creation');
    }
    body['emirates_id'] = emirates;

    final addressJson = address?.toJson();
    body['address'] =
        (addressJson == null || addressJson.isEmpty) ? null : addressJson;

    return body;
  }

  /// Swagger `PatientUpdate` body (partial).
  Map<String, dynamic> toUpdateJson() {
    final body = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'mobile': mobile.trim(),
      'dob': _formatDate(dob),
    };

    final emailValue = email?.trim();
    body['email'] =
        (emailValue == null || emailValue.isEmpty) ? null : emailValue;

    final addressJson = address?.toJson();
    body['address'] =
        (addressJson == null || addressJson.isEmpty) ? null : addressJson;

    return body;
  }

  PatientModel copyWith({
    String? id,
    String? uhid,
    String? hospitalId,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? gender,
    String? mobile,
    String? email,
    PatientAddress? address,
    String? emiratesId,
    String? source,
    bool? isActive,
  }) {
    return PatientModel(
      id: id ?? this.id,
      uhid: uhid ?? this.uhid,
      hospitalId: hospitalId ?? this.hospitalId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      emiratesId: emiratesId ?? this.emiratesId,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
    );
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
