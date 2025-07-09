import 'package:flutter/material.dart';

class SignupPatient extends StatelessWidget {
  const SignupPatient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Sign Up'),
      ),
      body: const Center(
        child: Text(
          'Patient Sign Up Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
