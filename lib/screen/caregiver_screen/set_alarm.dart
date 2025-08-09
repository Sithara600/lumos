import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/medication_service.dart';
import '../../models/medication.dart';
import 'patient_detail.dart'; // Import PatientDetailPage

class SetAlarmPage extends StatefulWidget {
  final String? patientId;
  
  const SetAlarmPage({super.key, this.patientId});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MedicationService _medicationService = MedicationService();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedMedicationId;
  String? _selectedMedicationName;
  String _selectedFrequency = 'Daily';
  final TextEditingController _notesController = TextEditingController();
  bool _alarmEnabled = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveAlarm() async {
    if (widget.patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient is not selected'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final String hour = _selectedTime.hour.toString().padLeft(2, '0');
      final String minute = _selectedTime.minute.toString().padLeft(2, '0');

      final docRef = _firestore.collection('alarms').doc();
      await docRef.set({
        'id': docRef.id,
        'patientId': widget.patientId,
        'medicationId': _selectedMedicationId,
        'medicationName': _selectedMedicationName,
        'time': '$hour:$minute',
        'hour': _selectedTime.hour,
        'minute': _selectedTime.minute,
        'frequency': _selectedFrequency,
        'notes': _notesController.text.trim(),
        'enabled': _alarmEnabled,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm saved'), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailPage(patientId: widget.patientId!),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save alarm: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        title: const Text('Set Alarm', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ),
            ),
            const SizedBox(height: 20),
              const Text('Medication', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (widget.patientId == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Open this page from a patient to select medication', style: TextStyle(fontSize: 16, color: Colors.black54)),
                ),
              ] else ...[
                StreamBuilder<List<Medication>>(
                  stream: _medicationService.getPatientMedications(widget.patientId!),
                  builder: (context, snapshot) {
                    final meds = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _selectedMedicationId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      hint: const Text('Select medication'),
                      items: meds.map((m) => DropdownMenuItem<String>(
                        value: m.id,
                        child: Text('${m.name} • ${m.dosage}', overflow: TextOverflow.ellipsis),
                      )).toList(),
                      validator: (val) {
                        if ((val == null || val.isEmpty) && meds.isNotEmpty) {
                          return 'Please select a medication';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _selectedMedicationId = val;
                          final med = meds.firstWhere((m) => m.id == val, orElse: () => Medication(
                            id: val ?? '', name: '', dosage: '', frequency: '', patientId: widget.patientId!, startDate: '', instructions: '', createdAt: DateTime.now(), caregiverId: '',
                          ));
                          _selectedMedicationName = med.name;
                        });
                      },
                    );
                  },
                ),
              ],
            const SizedBox(height: 20),
              const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                  DropdownMenuItem(value: 'Every 8 hours', child: Text('Every 8 hours')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                ],
                onChanged: (val) => setState(() => _selectedFrequency = val ?? 'Daily'),
              ),
            const SizedBox(height: 20),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional notes',
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _alarmEnabled,
                  onChanged: (val) {
                    setState(() {
                      _alarmEnabled = val;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9DBBFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                  onPressed: _isSaving ? null : _saveAlarm,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
          ),
        ),
      ),
    );
  }
}
