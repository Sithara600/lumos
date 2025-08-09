import 'package:flutter/material.dart';

class SoundHapticsPage extends StatefulWidget {
  const SoundHapticsPage({super.key});

  @override
  State<SoundHapticsPage> createState() => _SoundHapticsPageState();
}

class _SoundHapticsPageState extends State<SoundHapticsPage> {
  bool soundEffects = false;
  double soundEffectsVolume = 0.5;
  bool backgroundMusic = false;
  double backgroundMusicVolume = 0.7;
  bool hapticFeedback = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Sound & Haptics', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const Text('Sound', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Sound effects', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Enables sound effects for sections and events', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  ],
                ),
                Switch(
                  value: soundEffects,
                  onChanged: (val) {
                    setState(() {
                      soundEffects = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Sound effects volume', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            Slider(
              value: soundEffectsVolume,
              onChanged: (val) {
                setState(() {
                  soundEffectsVolume = val;
                });
              },
              min: 0,
              max: 1,
              activeColor: Colors.black,
              inactiveColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Background music', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Enables background music during gameplay', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  ],
                ),
                Switch(
                  value: backgroundMusic,
                  onChanged: (val) {
                    setState(() {
                      backgroundMusic = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Background Music Volume', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            Slider(
              value: backgroundMusicVolume,
              onChanged: (val) {
                setState(() {
                  backgroundMusicVolume = val;
                });
              },
              min: 0,
              max: 1,
              activeColor: Colors.black,
              inactiveColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text('Haptics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Haptic feedback', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('enables to haptick feedback for actions ans events', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  ],
                ),
                Switch(
                  value: hapticFeedback,
                  onChanged: (val) {
                    setState(() {
                      hapticFeedback = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            icon: Icon(Icons.book),
            label: 'Notification',
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
}
