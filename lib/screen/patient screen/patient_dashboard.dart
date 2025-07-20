import 'package:flutter/material.dart';
import 'emergency_call_amelia.dart';
import 'emergency_call_dr_john.dart';
import 'medication_detail.dart';
import 'patient_calender.dart';
import 'patient_profile.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
                builder: (context) => const PatientProfile(),
              ),
            );
          }
        },
      ),
    );
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
              color: color.withOpacity(0.1),
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
