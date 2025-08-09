import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'caregiver_dashboard.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({super.key});

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();

  String _selectedGender = 'Male';
  String? _foundPatientId;
  String? _statusMessage;
  bool _isLoading = false;
  bool _isSearching = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _findPatientByEmail() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter an email address to search.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundPatientId = null;
      _statusMessage = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim().toLowerCase())
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _foundPatientId = query.docs.first.id;
          _statusMessage = 'Patient found! You can now add this patient to your care.';
        });
      } else {
        setState(() {
          _statusMessage = 'No patient found with this email. You can create a new patient.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error searching for patient: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if patient already exists
      if (_foundPatientId != null) {
        // Add caregiver-patient relationship
        await FirebaseFirestore.instance
            .collection('caregiver_patients')
            .add({
          'caregiverId': user.uid,
          'patientId': _foundPatientId,
          'addedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _statusMessage = 'Patient added to your care successfully!';
        });
      } else {
        // Create new patient
        final docRef = await FirebaseFirestore.instance.collection('users').add({
          'fullName': _fullNameController.text.trim(),
          'dateOfBirth': _dobController.text.trim(),
          'gender': _selectedGender,
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'address': _addressController.text.trim(),
          'allergies': _allergiesController.text.trim(),
          'currentMedications': _medicationsController.text.trim(),
          'conditions': _conditionsController.text.trim(),
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
        });

        // Add caregiver-patient relationship
        await FirebaseFirestore.instance
            .collection('caregiver_patients')
            .add({
          'caregiverId': user.uid,
          'patientId': docRef.id,
          'addedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _statusMessage = 'New patient created and added to your care successfully!';
        });
      }

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(_statusMessage!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaregiverDashboard(),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Search existing patient section
              if (_foundPatientId == null) ...[
                const Text(
                  'Search Existing Patient',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter patient email to search for existing patients',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        controller: _emailController,
                        hint: 'patient@email.com',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSearching ? null : _findPatientByEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9EC1FA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Create new patient section
              const Text(
                'Create New Patient',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Full Name
              const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _fullNameController,
                hint: "Enter patient's full name",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              const Text('Date of Birth *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: _inputField(
                    controller: _dobController,
                    hint: 'MM/DD/YYYY (Tap to select)',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select date of birth';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              const Text('Gender *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              const Text('Phone Number *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _phoneController,
                hint: '(XXX) XXX-XXXX',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (if not found existing patient)
              if (_foundPatientId == null) ...[
                const Text('Email *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _inputField(
                  controller: _emailController,
                  hint: 'patient@email.com',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Address
              const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _addressController,
                hint: 'Enter patient address',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Allergies
              const Text('Allergies', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _allergiesController,
                hint: 'List any allergies (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Current Medications
              const Text('Current Medications', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _medicationsController,
                hint: 'List current medications (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Pre-existing Conditions
              const Text('Pre-existing Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _inputField(
                controller: _conditionsController,
                hint: 'List any pre-existing conditions (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC1FA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Patient', style: TextStyle(fontSize: 18)),
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage!.contains('Error') ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _statusMessage!.contains('Error') ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _statusMessage!.contains('Error') ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
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
