class Car {
  final int? id;
  final String model;
  final String engine;
  final String suspensions;
  final String gearbox;
  final String brakes;
  final String wheels;
  final String aero;

  Car({
    this.id,
    required this.model,
    required this.engine,
    required this.suspensions,
    required this.gearbox,
    required this.brakes,
    required this.wheels,
    required this.aero,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      model: json['model'] ?? '',
      engine: json['engine'] ?? '',
      suspensions: json['suspensions'] ?? '',
      gearbox: json['gearbox'] ?? '',
      brakes: json['brakes'] ?? '',
      wheels: json['wheels'] ?? '',
      aero: json['aero'] ?? '',
    );
  }
}
