class User {
  final int id;
  final String name;
  final String role;
  final int? carId;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.carId,
  });

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic carField = json.containsKey('carId')
        ? json['carId']
        : json['car'];

    int? parsedCarId;
    if (carField is Map<String, dynamic>) {
      parsedCarId = _toIntOrNull(carField['id']);
    } else {
      parsedCarId = _toIntOrNull(carField);
    }

    return User(
      id: _toIntOrNull(json['id']) ?? 0,
      name: (json['name'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      carId: parsedCarId,
    );
  }
}
