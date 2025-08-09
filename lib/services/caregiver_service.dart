import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class CaregiverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current caregiver ID
  String? get currentCaregiverId => _auth.currentUser?.uid;

  // Get caregiver's patients
  Future<List<Map<String, dynamic>>> getCaregiverPatients() async {
    try {
      String? caregiverId = currentCaregiverId;
      if (caregiverId == null) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('caregiver_patients')
          .where('caregiverId', isEqualTo: caregiverId)
          .get();

      List<Map<String, dynamic>> patients = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String patientId = data['patientId'];
        
        // Get patient details
        DocumentSnapshot patientDoc = await _firestore
            .collection('users')
            .doc(patientId)
            .get();
        
        if (patientDoc.exists) {
          Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
          patientData['id'] = patientId;
          patientData['relationshipId'] = doc.id;
          patients.add(patientData);
        }
      }

      return patients;
    } catch (e) {
      print('Error getting caregiver patients: $e');
      return [];
    }
  }

  // Add a new patient
  Future<bool> addPatient(String patientEmail, String relationship) async {
    try {
      String? caregiverId = currentCaregiverId;
      if (caregiverId == null) return false;

      // Find patient by email
      QuerySnapshot patientQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: patientEmail)
          .where('role', isEqualTo: 'patient')
          .get();

      if (patientQuery.docs.isEmpty) return false;

      String patientId = patientQuery.docs.first.id;

      // Check if relationship already exists
      QuerySnapshot existingRelationship = await _firestore
          .collection('caregiver_patients')
          .where('caregiverId', isEqualTo: caregiverId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existingRelationship.docs.isNotEmpty) return false;

      // Create relationship
      await _firestore.collection('caregiver_patients').add({
        'caregiverId': caregiverId,
        'patientId': patientId,
        'relationship': relationship,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error adding patient: $e');
      return false;
    }
  }

  // Remove a patient
  Future<bool> removePatient(String relationshipId) async {
    try {
      await _firestore
          .collection('caregiver_patients')
          .doc(relationshipId)
          .delete();
      return true;
    } catch (e) {
      print('Error removing patient: $e');
      return false;
    }
  }

  // Add medication for a patient
  Future<bool> addMedication(String patientId, Map<String, dynamic> medicationData) async {
    try {
      medicationData['patientId'] = patientId;
      medicationData['caregiverId'] = currentCaregiverId;
      medicationData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('medications').add(medicationData);
      return true;
    } catch (e) {
      print('Error adding medication: $e');
      return false;
    }
  }

  // Update medication
  Future<bool> updateMedication(String medicationId, Map<String, dynamic> medicationData) async {
    try {
      await _firestore
          .collection('medications')
          .doc(medicationId)
          .update(medicationData);
      return true;
    } catch (e) {
      print('Error updating medication: $e');
      return false;
    }
  }

  // Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      await _firestore
          .collection('medications')
          .doc(medicationId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting medication: $e');
      return false;
    }
  }

  // Get patient medications
  Future<List<Map<String, dynamic>>> getPatientMedications(String patientId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('medications')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting patient medications: $e');
      return [];
    }
  }

  // Get caregiver notifications
  Future<List<NotificationModel>> getCaregiverNotifications() async {
    try {
      String? caregiverId = currentCaregiverId;
      if (caregiverId == null) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('caregiverId', isEqualTo: caregiverId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting caregiver notifications: $e');
      return [];
    }
  }

  // Get notifications stream (for real-time updates)
  Stream<List<NotificationModel>> getNotifications() {
    String? caregiverId = currentCaregiverId;
    if (caregiverId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('caregiverId', isEqualTo: caregiverId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return NotificationModel.fromMap(data);
        }).toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get caregiver profile
  Future<Map<String, dynamic>?> getCaregiverProfile() async {
    try {
      String? caregiverId = currentCaregiverId;
      if (caregiverId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(caregiverId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting caregiver profile: $e');
      return null;
    }
  }

  // Update caregiver profile
  Future<void> updateCaregiverProfile(Map<String, dynamic> profileData) async {
    try {
      String? caregiverId = currentCaregiverId;
      if (caregiverId == null) return;

      await _firestore
          .collection('users')
          .doc(caregiverId)
          .update(profileData);
    } catch (e) {
      print('Error updating caregiver profile: $e');
    }
  }
} 