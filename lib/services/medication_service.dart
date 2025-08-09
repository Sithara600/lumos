import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new medication
  Future<void> addMedication(Medication medication) async {
    try {
      await _firestore.collection('medications').doc(medication.id).set(medication.toMap());
      print('Medication added successfully');
    } catch (e) {
      print('Error adding medication: $e');
      throw e;
    }
  }

  // Get medications for a specific patient
  Stream<List<Medication>> getPatientMedications(String patientId) {
    print('Querying medications for patientId: $patientId');
    return _firestore
        .collection('medications')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Received ${snapshot.docs.length} medications from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('Medication data: $data');
        return Medication.fromMap(data);
      }).toList();
    });
  }

  // Get medications added by a specific caregiver
  Stream<List<Medication>> getCaregiverMedications(String caregiverId) {
    return _firestore
        .collection('medications')
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Medication.fromMap(data);
      }).toList();
    });
  }

  // Update medication
  Future<void> updateMedication(Medication medication) async {
    try {
      await _firestore.collection('medications').doc(medication.id).update(medication.toMap());
      print('Medication updated successfully');
    } catch (e) {
      print('Error updating medication: $e');
      throw e;
    }
  }

  // Delete medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _firestore.collection('medications').doc(medicationId).delete();
      print('Medication deleted successfully');
    } catch (e) {
      print('Error deleting medication: $e');
      throw e;
    }
  }

  // Get a single medication by ID
  Future<Medication?> getMedicationById(String medicationId) async {
    try {
      final doc = await _firestore.collection('medications').doc(medicationId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Medication.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting medication: $e');
      throw e;
    }
  }
} 