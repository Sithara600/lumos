import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'caregiver_edit_profile.dart';
import 'add_patient.dart';
import '../app_setting/appsetting.dart';
import '../app_setting/notification.dart';
import '../patient_screen/patient_dashboard.dart';
import 'care_calender.dart';
import 'caregiver_profile.dart' show CaregiverProfile;
import 'patient_detail.dart';
import '../../services/caregiver_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification.dart';
import '../first_screen/first_screen.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CaregiverService _caregiverService = CaregiverService();
  final AuthService _authService = AuthService();
  int _unreadNotifications = 0;
  
  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }
  
  void _listenForNotifications() {
    _caregiverService.getNotifications().listen((notifications) {
      setState(() {
        _unreadNotifications = notifications.where((notification) => !notification.read).length;
      });
    });
  }

  Stream<List<Map<String, dynamic>>> _getPatientsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('caregiver_patients')
        .where('caregiverId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> patients = [];
      
      for (var doc in snapshot.docs) {
        final patientId = doc.data()['patientId'];
        try {
          final patientDoc = await _firestore.collection('users').doc(patientId).get();
          if (patientDoc.exists) {
            final patientData = patientDoc.data()!;
            patientData['id'] = patientDoc.id;
            patients.add(patientData);
          }
        } catch (e) {
          print('Error fetching patient $patientId: $e');
        }
      }
      
      return patients;
    });
  }

  Future<void> _switchToPatientAccount() async {
    try {
      // Show confirmation dialog
      bool? shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Switch Account'),
            content: const Text('Do you want to switch to a patient account? You will be asked to choose which patient.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Switch'),
              ),
            ],
          );
        },
      );

      if (shouldSwitch == true) {
        // Load patients for selection
        final user = _auth.currentUser;
        if (user == null) return;

        final cgPatientsSnap = await _firestore
            .collection('caregiver_patients')
            .where('caregiverId', isEqualTo: user.uid)
            .get();

        if (cgPatientsSnap.docs.isEmpty) {
          if (!mounted) return;
          // Prompt to add a patient first
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('No Patients Found'),
              content: const Text('You have no patients yet. Please add a patient before switching.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPatient()),
                    );
                  },
                  child: const Text('Add Patient'),
                ),
              ],
            ),
          );
          return;
        }

        // Fetch patient user docs
        final List<Map<String, dynamic>> patients = [];
        for (final rel in cgPatientsSnap.docs) {
          final patientId = rel.data()['patientId'];
          try {
            final patientDoc = await _firestore.collection('users').doc(patientId).get();
            if (patientDoc.exists) {
              final data = patientDoc.data()!;
              data['id'] = patientDoc.id;
              patients.add(data);
            }
          } catch (_) {}
        }

        if (!mounted) return;

        // Show selection dialog
        final String? selectedPatientId = await showDialog<String?>(
          context: context,
          builder: (ctx) {
            return SimpleDialog(
              title: const Text('Select patient account'),
              children: [
                for (final p in patients)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, p['id'] as String),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            (p['fullName'] ?? 'P').toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p['fullName'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );

        if (selectedPatientId != null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDashboard(patientId: selectedPatientId),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
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
                ],
              ),
              const SizedBox(height: 30),
              const Text('ACCOUNT', style: TextStyle(letterSpacing: 2, color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Dr. Amelia Harper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Text('ID:34257883', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CaregiverEditProfile(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('PATIENT', style: TextStyle(letterSpacing: 2, color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getPatientsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading patients: ${snapshot.error}'),
                    );
                  }

                  final patients = snapshot.data ?? [];

                  if (patients.isEmpty) {
                    // Show only the add patient button when no patients
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPatient(),
                                ),
                              );
                            },
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, color: Colors.blue, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Show patients in a scrollable row
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...patients.map((patient) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailPage(patientId: patient['id']),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              height: 140,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      patient['fullName']?.substring(0, 1).toUpperCase() ?? 'P',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    patient['fullName'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    patient['conditions']?.isNotEmpty == true 
                                        ? patient['conditions'].split(',').first.trim()
                                        : 'Patient',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PatientDetailPage(patientId: patient['id']),
                                        ),
                                      );
                                    },
                                    child: const Text('View Patient', style: TextStyle(color: Colors.blue)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                        // Add patient button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPatient(),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.blue, size: 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text('APP SETTINGS', style: TextStyle(letterSpacing: 2, color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: ListTile(
                  title: const Text('App Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSetting(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await _switchToPatientAccount();
                  },
                  child: const Text('Swith to patient account', style: TextStyle(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CareCalender(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ),
            ).then((_) => _listenForNotifications());
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverProfile(
                  onEditDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaregiverEditProfile(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
