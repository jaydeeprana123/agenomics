/// Matches Swagger `MedicineResponse`.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MedicineModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
