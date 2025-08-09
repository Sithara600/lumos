import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_medication.dart';
import 'set_alarm.dart';
import 'remove_patient.dart';
import '../../services/medication_service.dart';
import '../../models/medication.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;
  
  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MedicationService _medicationService = MedicationService();
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.patientId).get();
      if (doc.exists) {
        setState(() {
          _patientData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Patient not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading patient data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Patient Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatientData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _patientData?['fullName']?.substring(0, 1).toUpperCase() ?? 'P',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _patientData?['fullName'] ?? 'Unknown Patient',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _patientData?['email'] ?? 'No email',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      if (_patientData?['phoneNumber']?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          _patientData?['phoneNumber'] ?? '',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                      if (_patientData?['dateOfBirth']?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'DOB: ${_patientData?['dateOfBirth']}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                      if (_patientData?['gender']?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Gender: ${_patientData?['gender']}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                      const SizedBox(height: 32),
                      
                      // Patient Information Section
                      if (_patientData?['address']?.isNotEmpty == true ||
                          _patientData?['allergies']?.isNotEmpty == true ||
                          _patientData?['conditions']?.isNotEmpty == true) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text('Patient Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(height: 12),
                        if (_patientData?['address']?.isNotEmpty == true)
                          _infoItem('Address', _patientData!['address'], Icons.location_on),
                        if (_patientData?['allergies']?.isNotEmpty == true)
                          _infoItem('Allergies', _patientData!['allergies'], Icons.warning),
                        if (_patientData?['conditions']?.isNotEmpty == true)
                          _infoItem('Conditions', _patientData!['conditions'], Icons.medical_services),
                        const SizedBox(height: 32),
                      ],

                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Medications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<Medication>>(
                        stream: _medicationService.getPatientMedications(widget.patientId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading medications: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                          }
                          final meds = snapshot.data ?? [];
                          if (meds.isEmpty) {
                            return const Text('No medications listed', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                          }
                          return Column(
                            children: meds.map((m) => _medicationItem(m.name, '${m.dosage} • ${m.frequency}')).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMedication(patientId: widget.patientId),
                              ),
                            );
                          },
                          child: const Text('+ Add Medication', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Alarms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 12),
                      _alarmItem('08:00 AM'),
                      _alarmItem('12:00 PM'),
                      _alarmItem('06:00 PM'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetAlarmPage(patientId: widget.patientId),
                              ),
                            );
                          },
                          child: const Text('+ Add Alarm', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RemovePatientPage(patientId: widget.patientId),
                            ),
                          );
                        },
                        child: const Text('Remove Patient', style: TextStyle(color: Colors.black, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(content, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationItem(String name, String dose) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, size: 24, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(dose, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _alarmItem(String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time, size: 24, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
