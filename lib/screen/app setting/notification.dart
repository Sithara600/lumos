import 'package:flutter/material.dart';
import '../patient setting/patient_app_setting.dart'; // Import PatientAppSettingPage

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            _notificationItem(
              avatar: 'assets/user1.png',
              title: 'New message from Brian',
              subtitle: 'sofiya sent you a message',
            ),
            _notificationItem(
              icon: Icons.account_circle,
              iconBg: const Color(0xFFB3C7F7),
              title: 'Account updates',
              subtitle: '',
            ),
            _notificationItem(
              avatar: 'assets/user1.png',
              title: 'Brian get medications',
              subtitle: 'sofiya  get the morning tablet',
            ),
            _notificationItem(
              avatar: 'assets/user1.png',
              title: 'Brian get morning meals',
              subtitle: '',
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
              onTap: () {},
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
      ),
    );
  }

  Widget _notificationItem({String? avatar, IconData? icon, Color? iconBg, required String title, required String subtitle}) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
