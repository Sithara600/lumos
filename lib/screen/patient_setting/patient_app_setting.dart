import 'package:flutter/material.dart';
import '../patient_screen/login/login_patient.dart';

class PatientAppSettingPage extends StatelessWidget {
  const PatientAppSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('App Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            _settingTile(context, Icons.notifications, 'Notification'),
            const SizedBox(height: 16),
            _settingTile(context, Icons.volume_up, 'Sound & Haptics'),
            const SizedBox(height: 16),
            _settingTile(context, Icons.privacy_tip, 'Privacy'),
            const SizedBox(height: 16),
            _settingTile(context, Icons.help_outline, 'Help'),
            const SizedBox(height: 40),
            const Text('Your Account', style: TextStyle(color: Colors.black38)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Navigation removed as requested
              },
              child: const Text('Switch to other Account', style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline)),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Navigation logic for bottom bar
        },
      ),
    );
  }

  Widget _settingTile(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
        onTap: () {
          // Navigation logic for each setting
        },
      ),
    );
  }
}
