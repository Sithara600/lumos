import 'package:flutter/material.dart';
import 'caregiver_dashboard.dart';

class AddPatient extends StatelessWidget {
  const AddPatient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Add New Patient',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: "Enter patient's full name"),
            const SizedBox(height: 16),
            const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: 'MM/DD/YYYY'),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: ''),
            const SizedBox(height: 16),
            const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: '(XXX) XXX-XXXX'),
            const SizedBox(height: 16),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: 'patient@email.com'),
            const SizedBox(height: 16),
            const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: '', maxLines: 3),
            const SizedBox(height: 16),
            const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: '', maxLines: 3),
            const SizedBox(height: 16),
            const Text('Current Medications', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: '', maxLines: 3),
            const SizedBox(height: 16),
            const Text('Pre-existing Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _inputField(hint: '', maxLines: 3),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaregiverDashboard(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9EC1FA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _inputField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
