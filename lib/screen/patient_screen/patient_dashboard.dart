import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'emergency_call_amelia.dart';
import 'emergency_call_dr_john.dart';
import 'medication_detail.dart';
import 'patient_calender.dart';

import '../patient screen/patient_notification.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';

import '../first_screen/first_screen.dart';

class PatientDashboard extends StatefulWidget {
  final String? patientId; // Optional override when navigating as caregiver
  const PatientDashboard({super.key, this.patientId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PatientService _patientService = PatientService();
  final AuthService _authService = AuthService();
  int _unreadNotifications = 0;
  String? _activePatientId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activePatientId = widget.patientId ?? _auth.currentUser?.uid;
    _listenForNotifications();
    // Force refresh when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
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


  
  void _listenForNotifications() {
    if (_activePatientId != null) {
      _patientService.getNotifications(_activePatientId!).listen((notifications) {
        setState(() {
          _unreadNotifications = notifications.where((notification) => !notification.read).length;
        });
      });
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FirstScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the default back arrow only for this page
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientNotification(),
                    ),
                  ).then((_) => _listenForNotifications());
                },
                tooltip: 'Notifications',
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotifications > 9 ? '9+' : _unreadNotifications.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Show patient ID (UID)
            if (_auth.currentUser == null) // This block is removed
              Card(
                color: Colors.red[50],
                margin: const EdgeInsets.only(bottom: 16),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Patient ID not set. Please contact your caregiver or admin.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            const Text('Upcoming Appointments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            _appointmentTile(
              image: Icons.event_note,
              title: 'General Checkup',
              subtitle: 'Dr. Amelia Carter',
              date: 'July 15, 2024',
            ),
            _appointmentTile(
              image: Icons.fitness_center,
              title: 'Physical Therapy',
              subtitle: 'Dr. Noah Thompson',
              date: 'July 22, 2024',
            ),
            const SizedBox(height: 20),
            // Alarms section
            if (_activePatientId != null) ...[
              const Text('Alarms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('alarms')
                    .where('patientId', isEqualTo: _activePatientId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading alarms: ${snapshot.error}');
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text('No alarms set', style: TextStyle(color: Colors.black54));
                  }
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final bool enabled = (data['enabled'] ?? true) as bool;
                      final String time = (data['time'] ?? '') as String;
                      final String medicationName = (data['medicationName'] ?? 'Medication') as String;
                      final String frequency = (data['frequency'] ?? 'Daily') as String;
                      final Timestamp? snoozedUntilTs = data['snoozedUntil'] as Timestamp?;
                      DateTime? snoozedUntil = snoozedUntilTs?.toDate();
                      final bool isSnoozedActive = snoozedUntil != null && snoozedUntil.isAfter(DateTime.now());

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.access_time, size: 28, color: Colors.black54),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(medicationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(
                                    isSnoozedActive
                                        ? 'Snoozed until: ${_formatTimeOfDay(TimeOfDay(hour: snoozedUntil!.hour, minute: snoozedUntil.minute))}'
                                        : '$time • $frequency',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            if (enabled)
                              TextButton(
                                onPressed: () => _snoozeAlarm(doc.id, minutes: 5),
                                child: const Text('Snooze 5m'),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            const Text('Current Medications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            _medicationTile(
              name: 'Lisinopril',
              details: '10mg, Once Daily\nTake with food',
              pillsLeft: '30 pills left',
            ),
            _medicationTile(
              name: 'Metformin',
              details: '500mg, Twice Daily\nTake after meals',
              pillsLeft: '60 pills left',
            ),
            const SizedBox(height: 20),
            const Text('Recent Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            _updateTile(
              icon: Icons.description,
              color: Colors.blue,
              title: 'Lab Results',
              subtitle: 'Lab results are normal',
              time: '2 days ago',
            ),
            _updateTile(
              icon: Icons.notifications_none,
              color: Colors.black,
              title: 'Appointment Reminder',
              subtitle: 'Schedule your next visit',
              time: '1 week ago',
            ),
            const SizedBox(height: 20),
            const Text('Care Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            _careTeamTile(
              name: 'Amelia Carter',
              role: 'Daughter',
              avatarColor: Colors.blue,
            ),
            _careTeamTile(
              name: 'Dr. John',
              role: '',
              avatarColor: Colors.green,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calender',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _unreadNotifications > 9 ? '9+' : _unreadNotifications.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicationDetail(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientCalendar(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientNotification(),
              ),
            ).then((_) => _listenForNotifications());
          }
        },
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final local = TimeOfDay.fromDateTime(dt);
    final String h = local.hourOfPeriod.toString().padLeft(2, '0');
    final String m = local.minute.toString().padLeft(2, '0');
    final String ap = local.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ap';
  }

  Future<void> _snoozeAlarm(String alarmId, {int minutes = 5}) async {
    try {
      final DateTime snoozeUntil = DateTime.now().add(Duration(minutes: minutes));
      await _firestore.collection('alarms').doc(alarmId).update({
        'snoozedUntil': Timestamp.fromDate(snoozeUntil),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm snoozed for $minutes minutes')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to snooze alarm: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _appointmentTile({required IconData image, required String title, required String subtitle, required String date}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(image, size: 28, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _medicationTile({required String name, required String details, required String pillsLeft}) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicationDetail(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication, size: 28, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(details, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              Text(pillsLeft, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateTile({required IconData icon, required Color color, required String title, required String subtitle, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _careTeamTile({required String name, required String role, required Color avatarColor}) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: name.toLowerCase() == 'amelia carter' || role.toLowerCase() == 'daughter'
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyCall(),
                        ),
                      );
                    }
                  : name.toLowerCase() == 'dr. john'
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyCallDrJohn(),
                          ),
                        );
                      }
                    : null,
              child: CircleAvatar(
                backgroundColor: avatarColor,
                child: Text(name[0], style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: name.toLowerCase() == 'amelia carter' || role.toLowerCase() == 'daughter'
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyCall(),
                          ),
                        );
                      }
                    : name.toLowerCase() == 'dr. john'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyCallDrJohn(),
                            ),
                          );
                        }
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (role.isNotEmpty)
                      Text(role, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
