import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../constants.dart';

class CarService {
  Future<Car> fetchCar(int userId) async {
    final uri = Uri.parse("$kApiBaseUrl/car/$userId");

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Failed to load car: ${res.body}");
    }

    return Car.fromJson(jsonDecode(res.body));
  }

  Future<Car> createOrReplaceCar(int userId, Car car) async {
    final uri = Uri.parse('$kApiBaseUrl/car/$userId');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': car.id,
        'model': car.model,
        'engine': car.engine,
        'suspensions': car.suspensions,
        'gearbox': car.gearbox,
        'brakes': car.brakes,
        'wheels': car.wheels,
        'aero': car.aero,
      }),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to save car (${res.statusCode}): ${res.body}');
    }

    return Car.fromJson(jsonDecode(res.body));
  }
}
