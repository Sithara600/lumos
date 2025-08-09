import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareCalender extends StatefulWidget {
  const CareCalender({super.key});

  @override
  State<CareCalender> createState() => _CareCalenderState();
}

class _CareCalenderState extends State<CareCalender> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime _displayedMonth; // First day of month for the calendar header
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month);
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day).add(const Duration(days: 1));

  Future<void> _addNote() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not signed in'), backgroundColor: Colors.red),
      );
      return;
    }

    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write a note for the selected date',
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a note' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('care_notes').add({
          'caregiverId': user.uid,
          'noteDate': Timestamp.fromDate(_startOfDay(_selectedDate)),
          'noteText': controller.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
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
            _CalendarWidget(
              displayedMonth: _displayedMonth,
              selectedDate: _selectedDate,
              onPrevMonth: () {
                setState(() {
                  _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                  // Keep selected day within displayed month
                  _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
                });
              },
              onNextMonth: () {
                setState(() {
                  _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                  _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
                });
              },
              onSelectDay: (day) {
                setState(() {
                  _selectedDate = day;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              _formatFullDate(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (user != null)
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('care_notes')
                      .where('caregiverId', isEqualTo: user.uid)
                      .where('noteDate', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay(_selectedDate)))
                      .where('noteDate', isLessThan: Timestamp.fromDate(_endOfDay(_selectedDate)))
                      .orderBy('noteDate')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No notes for this day'));
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final data = docs[i].data();
                        return _eventTile(Icons.event_note, data['noteText'] ?? '', '');
                      },
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Please sign in to view notes'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9DB8FF),
        onPressed: _addNote,
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
  final DateTime displayedMonth; // first day of displayed month
  final DateTime selectedDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime day) onSelectDay;

  const _CalendarWidget({
    required this.displayedMonth,
    required this.selectedDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  String _monthTitle(DateTime month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // make Sunday=0
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    final List<Widget> dayHeaders = const [
      'S', 'M', 'T', 'W', 'T', 'F', 'S'
    ].map((d) => Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.bold)))).toList();

    final List<TableRow> rows = [];
    rows.add(TableRow(children: dayHeaders));

    int dayCounter = 1;
    // Up to 6 weeks rows
    for (int week = 0; week < 6; week++) {
      final List<Widget> cells = [];
      for (int dow = 0; dow < 7; dow++) {
        final cellIndex = week * 7 + dow;
        if (cellIndex < firstWeekday || dayCounter > daysInMonth) {
          cells.add(const SizedBox(height: 40));
        } else {
          final current = DateTime(displayedMonth.year, displayedMonth.month, dayCounter);
          final bool isSelected = current.year == selectedDate.year && current.month == selectedDate.month && current.day == selectedDate.day;
          cells.add(_calendarDayCell(current, isSelected));
          dayCounter++;
        }
      }
      rows.add(TableRow(children: cells));
      if (dayCounter > daysInMonth) break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevMonth,
            ),
            Text(_monthTitle(displayedMonth), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Table(children: rows),
      ],
    );
  }

  Widget _calendarDayCell(DateTime day, bool selected) {
    return InkWell(
      onTap: () => onSelectDay(day),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: selected
              ? Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9DB8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              : Text('${day.day}'),
        ),
      ),
    );
  }
}

String _formatFullDate(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final weekday = weekdays[d.weekday % 7];
  final month = months[d.month - 1];
  return '$weekday, $month ${d.day}, ${d.year}';
}
