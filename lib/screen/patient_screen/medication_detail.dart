import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

class MedicationDetail extends StatefulWidget {
  const MedicationDetail({super.key});

  @override
  State<MedicationDetail> createState() => _MedicationDetailState();
}

class _MedicationDetailState extends State<MedicationDetail> with WidgetsBindingObserver {
  final MedicationService _medicationService = MedicationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view medications'),
        ),
      );
    }

    print('=== DEBUG INFO ===');
    print('Current user ID: ${user.uid}');
    print('Looking for medications with patientId: ${user.uid}');
    print('==================');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Medication Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            onPressed: () => _debugAllMedications(),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.green),
            onPressed: () => _testQuery(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Medication>>(
        key: ValueKey(user.uid), // Force refresh when user changes
        stream: _medicationService.getPatientMedications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error loading medications: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final medications = snapshot.data ?? [];
          print('Found ${medications.length} medications');

          if (medications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No medications found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your caregiver will add medications here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return _medicationCard(medication);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _medicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9DB8FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    size: 28,
                    color: Color(0xFF9DB8FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.dosage,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Frequency', medication.frequency),
            _detailRow('Start Date', medication.startDate),
            if (medication.endDate != null)
              _detailRow('End Date', medication.endDate!),
            _detailRow('Instructions', medication.instructions),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9DB8FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Added on ${_formatDate(medication.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9DB8FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _debugAllMedications() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('medications').get();
      print('=== ALL MEDICATIONS IN DATABASE ===');
      print('Total medications found: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('Medication ID: ${doc.id}');
        print('Patient ID: ${data['patientId']}');
        print('Name: ${data['name']}');
        print('Caregiver ID: ${data['caregiverId']}');
        print('---');
      }
      print('=====================================');
      
      // Also check current user
      final user = _auth.currentUser;
      print('Current user ID: ${user?.uid}');
      print('Current user email: ${user?.email}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${snapshot.docs.length} medications. Current user: ${user?.uid}'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error debugging medications: $e');
    }
  }

  Future<void> _testQuery() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      print('=== TESTING QUERY ===');
      print('Querying for patientId: ${user.uid}');
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('patientId', isEqualTo: user.uid)
          .get();
      
      print('Query returned ${querySnapshot.docs.length} documents');
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('Found medication: ${data['name']} for patient: ${data['patientId']}');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query test: ${querySnapshot.docs.length} medications found'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error testing query: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
