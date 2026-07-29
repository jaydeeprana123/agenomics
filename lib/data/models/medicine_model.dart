/// Matches Swagger `MedicineResponse` / `MedicineCreate` / `MedicineUpdate`.
class MedicineModel {
  final String id;
  final String name;
  final bool requiresOncologyCheck;
  final DateTime? createdAt;

  const MedicineModel({
    required this.id,
    required this.name,
    this.requiresOncologyCheck = false,
    this.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      requiresOncologyCheck: json['requires_oncology_check'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'requires_oncology_check': requiresOncologyCheck,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Swagger `MedicineCreate` body.
  Map<String, dynamic> toCreateJson() => {
        'name': name.trim(),
        'requires_oncology_check': requiresOncologyCheck,
      };

  /// Swagger `MedicineUpdate` body.
  Map<String, dynamic> toUpdateJson() => {
        'name': name.trim(),
        'requires_oncology_check': requiresOncologyCheck,
      };

  MedicineModel copyWith({
    String? id,
    String? name,
    bool? requiresOncologyCheck,
    DateTime? createdAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      requiresOncologyCheck:
          requiresOncologyCheck ?? this.requiresOncologyCheck,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MedicineModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
