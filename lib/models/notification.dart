// ... existing code ...
// notification.dart
// This file defines the NotificationModel class, which represents a notification
// in the dementia care app. It includes properties for the notification's details,
// and methods to convert between Dart objects and Firestore data.

import 'package:cloud_firestore/cloud_firestore.dart';

// This class represents a notification in the app
class NotificationModel {
  // Unique ID for the notification (usually from Firestore)
  final String id;

  // Title of the notification (e.g., "Medication Reminder")
  final String title;

  // The main message or body of the notification
  final String message;

  // The type of notification (e.g., 'medication', 'appointment', 'emergency', 'general')
  final String type;

  // The ID of the patient related to this notification (if any)
  final String? patientId;

  // The ID of the caregiver related to this notification (if any)
  final String? caregiverId;

  // When the notification was created
  final DateTime timestamp;

  // Whether the notification has been read
  final bool isRead;

  // Any extra data related to the notification
  final Map<String, dynamic>? additionalData;

  // These are extra properties for compatibility with other parts of the app
  String get body => message; // Returns the message as the body
  bool get read => isRead;    // Returns the read status

  // Constructor to create a NotificationModel object
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.patientId,
    this.caregiverId,
    required this.timestamp,
    this.isRead = false,
    this.additionalData,
  });

  // Factory method to create a NotificationModel from a map (like from Firestore)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '', // Use empty string if id is missing
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      patientId: map['patientId'],
      caregiverId: map['caregiverId'],
      // Convert Firestore Timestamp to DateTime, or use current time if missing
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      additionalData: map['additionalData'],
    );
  }

  // Convert a NotificationModel object to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'timestamp': Timestamp.fromDate(timestamp), // Store as Firestore Timestamp
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  // Create a copy of this notification, with some fields changed if needed
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? patientId,
    String? caregiverId,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // For debugging: get a string that describes this notification
  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, message: $message, type: $type, isRead: $isRead)';
  }

  // For comparing two notifications: they are equal if their IDs are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  // Hash code for using this object in sets or as map keys
  @override
  int get hashCode => id.hashCode;
}
// ... existing code ...