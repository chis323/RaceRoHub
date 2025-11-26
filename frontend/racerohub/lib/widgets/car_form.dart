// widgets/car_form.dart
import 'package:flutter/material.dart';
import 'package:racerohub/models/car.dart';
import 'package:racerohub/services/car_service.dart';

class CarForm extends StatefulWidget {
  final int userId;
  final void Function(Car) onSaved;

  const CarForm({super.key, required this.userId, required this.onSaved});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();
  final _modelCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _suspCtrl = TextEditingController();
  final _gearboxCtrl = TextEditingController();
  final _brakesCtrl = TextEditingController();
  final _wheelsCtrl = TextEditingController();
  final _aeroCtrl = TextEditingController();

  bool _submitting = false;
  final _svc = CarService();

  @override
  void dispose() {
    _modelCtrl.dispose();
    _engineCtrl.dispose();
    _suspCtrl.dispose();
    _gearboxCtrl.dispose();
    _brakesCtrl.dispose();
    _wheelsCtrl.dispose();
    _aeroCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final car = Car(
        id: null,
        model: _modelCtrl.text.trim(),
        engine: _engineCtrl.text.trim(),
        suspensions: _suspCtrl.text.trim(),
        gearbox: _gearboxCtrl.text.trim(),
        brakes: _brakesCtrl.text.trim(),
        wheels: _wheelsCtrl.text.trim(),
        aero: _aeroCtrl.text.trim(),
      );

      final saved = await _svc.createOrReplaceCar(widget.userId, car);

      if (!mounted) return;
      widget.onSaved(saved);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Car saved successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save car: $e')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // 👈 helps when keyboard is open
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your car',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Model *',
                    hintText: 'e.g. BMW M3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Model is required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _engineCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Engine *',
                    hintText: 'e.g. 3.0L Twin Turbo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Engine is required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _suspCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Suspensions',
                    hintText: 'e.g. Sport, Coilovers',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _gearboxCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Gearbox',
                    hintText: 'e.g. Manual, DCT',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _brakesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Brakes',
                    hintText: 'e.g. Carbon Ceramic',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _wheelsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Wheels',
                    hintText: 'e.g. 19 inch',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _aeroCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Aero',
                    hintText: 'e.g. Rear wing, splitter',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save car'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
