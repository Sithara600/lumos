import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current patient ID
  String? get currentPatientId => _auth.currentUser?.uid;

  // Get patient medications
  Future<List<Map<String, dynamic>>> getPatientMedications() async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('medications')
          .where('patientId', isEqualTo: patientId)
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

  // Get patient appointments
  Future<List<Map<String, dynamic>>> getPatientAppointments() async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting patient appointments: $e');
      return [];
    }
  }

  // Get patient notifications
  Future<List<NotificationModel>> getPatientNotifications() async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return [];

      QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting patient notifications: $e');
      return [];
    }
  }

  // Get notifications stream (for real-time updates)
  Stream<List<NotificationModel>> getNotifications(String patientId) {
    return _firestore
        .collection('notifications')
        .where('patientId', isEqualTo: patientId)
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

  // Get patient profile
  Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(patientId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting patient profile: $e');
      return null;
    }
  }

  // Update patient profile
  Future<void> updatePatientProfile(Map<String, dynamic> profileData) async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return;

      await _firestore
          .collection('users')
          .doc(patientId)
          .update(profileData);
    } catch (e) {
      print('Error updating patient profile: $e');
    }
  }

  // Emergency call
  Future<void> makeEmergencyCall(String emergencyContact) async {
    try {
      String? patientId = currentPatientId;
      if (patientId == null) return;

      await _firestore.collection('emergency_calls').add({
        'patientId': patientId,
        'emergencyContact': emergencyContact,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending'
      });
    } catch (e) {
      print('Error making emergency call: $e');
    }
  }
} 