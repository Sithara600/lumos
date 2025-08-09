import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'caregiver_dashboard.dart';
import 'patient_detail.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

class AddMedication extends StatefulWidget {
  final String? patientId;
  
  const AddMedication({super.key, this.patientId});

  @override
  State<AddMedication> createState() => _AddMedicationState();
}

class _AddMedicationState extends State<AddMedication> {
  final _formKey = GlobalKey<FormState>();
  final _medicationService = MedicationService();
  final _auth = FirebaseAuth.instance;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill patient ID if provided
    if (widget.patientId != null) {
      _patientIdController.text = widget.patientId!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _patientIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final medication = Medication(
        id: FirebaseFirestore.instance.collection('medications').doc().id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        patientId: _patientIdController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim().isEmpty ? null : _endDateController.text.trim(),
        instructions: _instructionsController.text.trim(),
        createdAt: DateTime.now(),
        caregiverId: user.uid,
      );

      await _medicationService.addMedication(medication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        final String targetPatientId = widget.patientId ?? _patientIdController.text.trim();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailPage(patientId: targetPatientId),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medication: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Add Medication',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Medication Name
              const Text('Medication Name *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _nameController,
                hint: 'Enter medication name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dosage
              const Text('Dosage *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _dosageController,
                hint: 'e.g., 500mg, 1 tablet',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency
              const Text('Frequency *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _frequencyController,
                hint: 'e.g., Twice daily, Every 8 hours',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter frequency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Patient ID (show only if not pre-selected)
              if (widget.patientId == null) ...[
                const Text('Patient ID *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _inputField(
                  controller: _patientIdController,
                  hint: 'Enter patient ID',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Start Date
              const Text('Start Date *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _selectDate(context, _startDateController),
                child: AbsorbPointer(
                  child: _inputField(
                    controller: _startDateController,
                    hint: 'YYYY-MM-DD (Tap to select)',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date (Optional)
              const Text('End Date (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _selectDate(context, _endDateController),
                child: AbsorbPointer(
                  child: _inputField(
                    controller: _endDateController,
                    hint: 'YYYY-MM-DD (Tap to select)',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _instructionsController,
                hint: 'Enter any special instructions',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC1FA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Medication', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
