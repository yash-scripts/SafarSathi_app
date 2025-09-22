import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/trip_service.dart';

class ManualTripScreen extends StatefulWidget {
  const ManualTripScreen({super.key});

  @override
  State<ManualTripScreen> createState() => _ManualTripScreenState();
}

class _ManualTripScreenState extends State<ManualTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();

  DateTime? _startTime;
  DateTime? _endTime;
  double? _distance;
  double? _avgSpeed;

  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    if (!mounted) return;

    setState(() {
      _startTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
      _startTimeController.text = DateFormat.yMd().add_Hms().format(_startTime!);
    });
  }

  Future<void> _selectEndTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime ?? now,
      firstDate: _startTime ?? DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime ?? now),
    );
    if (time == null) return;

    if (!mounted) return;

    setState(() {
      _endTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
      _endTimeController.text = DateFormat.yMd().add_Hms().format(_endTime!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Manual Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time'),
                onTap: _selectStartTime,
                validator: (value) {
                  if (_startTime == null) {
                    return 'Please select a start time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: const InputDecoration(labelText: 'End Time'),
                onTap: _selectEndTime,
                validator: (value) {
                  if (_endTime == null) {
                    return 'Please select an end time';
                  }
                  if (_startTime != null && _endTime!.isBefore(_startTime!)) {
                    return 'End time cannot be before start time';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _distance = double.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid distance';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Average Speed (km/h)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _avgSpeed = double.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid average speed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _tripService.addManualTrip(
                      _startTime!,
                      _endTime!,
                      _distance! * 1000, // Convert km to meters
                      _avgSpeed! / 3.6, // Convert km/h to m/s
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
