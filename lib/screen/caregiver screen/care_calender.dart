import 'package:flutter/material.dart';

class CareCalender extends StatelessWidget {
  const CareCalender({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Care Calendar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _CalendarWidget(),
            const SizedBox(height: 24),
            const Text('October 15, 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _eventTile(Icons.medication, 'Medication Reminder', '8:00 AM'),
            _eventTile(Icons.calendar_today, "Doctor's Appointment", '10:00 AM'),
            _eventTile(Icons.person, 'Physical Therapy', '2:00 PM'),
            _eventTile(Icons.restaurant, 'Dinner', '6:00 PM'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9DB8FF),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  static Widget _eventTile(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {},
            ),
            const Text('October 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Table(
          children: [
            const TableRow(
              children: [
                Center(child: Text('S', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('M', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('F', style: TextStyle(fontWeight: FontWeight.bold))),
                Center(child: Text('S', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            TableRow(
              children: [
                _calendarDay('1'), _calendarDay('2'), _calendarDay('3'), _calendarDay('4'), _calendarDayCircle('5'), _calendarDay('6'), _calendarDay('7'),
              ],
            ),
            TableRow(
              children: [
                _calendarDay('8'), _calendarDay('9'), _calendarDay('10'), _calendarDay('11'), _calendarDay('12'), _calendarDay('13'), _calendarDay('14'),
              ],
            ),
            TableRow(
              children: [
                _calendarDay('15'), _calendarDay('16'), _calendarDay('17'), _calendarDay('18'), _calendarDay('19'), _calendarDay('20'), _calendarDay('21'),
              ],
            ),
            TableRow(
              children: [
                _calendarDay('22'), _calendarDay('23'), _calendarDay('24'), _calendarDay('25'), _calendarDay('26'), _calendarDay('27'), _calendarDay('28'),
              ],
            ),
            TableRow(
              children: [
                _calendarDay('29'), _calendarDay('30'), const SizedBox(), const SizedBox(), const SizedBox(), const SizedBox(), const SizedBox(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _calendarDay(String day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(child: Text(day)),
    );
  }

  static Widget _calendarDayCircle(String day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF9DB8FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
