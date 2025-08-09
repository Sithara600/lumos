import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/notification.dart';
import '../../services/patient_service.dart';
import '../../services/caregiver_service.dart';
import '../../services/auth_service.dart';
import '../patient_setting/patient_app_setting.dart'; // Import PatientAppSettingPage
import '../patient_screen/login/login_patient.dart'; // Import LoginPatient

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  final CaregiverService _caregiverService = CaregiverService();
  
  String? _userRole;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndNotifications();
  }

  Future<void> _loadUserRoleAndNotifications() async {
    if (_auth.currentUser != null) {
      // Get user role
      _userRole = await _authService.getUserRole(_auth.currentUser!.uid);
      
      // Get notifications based on role
      if (_userRole == 'patient') {
        _patientService.getNotifications(_auth.currentUser!.uid).listen((notifications) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        });
      } else if (_userRole == 'caregiver') {
        _caregiverService.getNotifications().listen((notifications) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (_userRole == 'patient') {
      await _patientService.markNotificationAsRead(notification.id);
    } else if (_userRole == 'caregiver') {
      await _caregiverService.markNotificationAsRead(notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Notification', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 20),
                Expanded(
                  child: _notifications.isEmpty
                    ? const Center(child: Text('No notifications'))
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return GestureDetector(
                            onTap: () => _markAsRead(notification),
                            child: _notificationItem(
                              icon: notification.read ? Icons.notifications_none : Icons.notifications_active,
                              iconBg: notification.read ? Colors.grey[300] : const Color(0xFFB3C7F7),
                              title: notification.title,
                              subtitle: notification.body,
                              isRead: notification.read,
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 32),
                const Text('Your Account', style: TextStyle(color: Colors.black38)),
                const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientAppSettingPage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Switch to other Account', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPatient(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calender',
          ),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _notificationItem({String? avatar, IconData? icon, Color? iconBg, required String title, required String subtitle, bool isRead = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (avatar != null)
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(avatar),
            )
          else if (icon != null)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold, 
                    fontSize: 16
                  )
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle, 
                    style: TextStyle(
                      color: isRead ? Colors.black38 : Colors.black54, 
                      fontSize: 13
                    )
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
