import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Patient Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
