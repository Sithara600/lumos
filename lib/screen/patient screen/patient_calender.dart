import 'package:flutter/material.dart';

class PatientCalendar extends StatelessWidget {
  const PatientCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'My Calendar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _calendarHeader(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('October 15, 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            _eventTile(
              icon: Icons.notifications_active_outlined,
              iconBg: Color(0xFFFFF7E0),
              iconColor: Color(0xFFFFC107),
              title: 'Medication Reminder',
              time: '8:00 AM',
            ),
            _eventTile(
              icon: Icons.calendar_month,
              iconBg: Color(0xFFE6F0FF),
              iconColor: Color(0xFF2196F3),
              title: "Doctor's Appointment",
              time: '10:00 AM',
            ),
            _eventTile(
              icon: Icons.fitness_center,
              iconBg: Color(0xFFE6F7F0),
              iconColor: Color(0xFF4CAF50),
              title: 'Physical Therapy',
              time: '2:00 PM',
            ),
            _eventTile(
              icon: Icons.dinner_dining,
              iconBg: Color(0xFFFFE6E6),
              iconColor: Color(0xFFFF7043),
              title: 'Dinner',
              time: '6:00 PM',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {},
      ),
    );
  }

  Widget _calendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
              ),
              const Text('October 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _calendarGrid(),
        ],
      ),
    );
  }

  Widget _calendarGrid() {
    // This is a static calendar for October 2024 with the 15th selected
    final days = [
      ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
      [' ', ' ', '1', '2', '3', '4', '5'],
      ['6', '7', '8', '9', '10', '11', '12'],
      ['13', '14', '15', '16', '17', '18', '19'],
      ['20', '21', '22', '23', '24', '25', '26'],
      ['27', '28', '29', '30', ' ', ' ', ' '],
    ];
    return Table(
      children: days.map((week) {
        return TableRow(
          children: week.map((day) {
            final isSelected = day == '15';
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: isSelected
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9EC1FA),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    : Text(day, style: const TextStyle(fontSize: 16)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _eventTile({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(time, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
