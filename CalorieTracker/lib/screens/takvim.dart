import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/db_helper.dart';
import '../models/yiyecek.dart';

class TakvimScreen extends StatefulWidget {
  final Map<DateTime, List<Yiyecek>> yiyecekKayitlari;

  TakvimScreen({required this.yiyecekKayitlari});

  @override
  _TakvimScreenState createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  late DBHelper _dbHelper;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Yiyecek> _selectedYiyecekler = [];
  Map<DateTime, int> _gunlukKaloriler = {};

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    _selectedDay = _focusedDay;
    _selectedYiyecekler = widget.yiyecekKayitlari[_selectedDay] ?? [];
    _loadAllGunlukKaloriler();
  }

  Future<void> _loadAllGunlukKaloriler() async {
    for (var entry in widget.yiyecekKayitlari.entries) {
      final kalori = await _dbHelper.getirGunlukKalori(entry.key);
      if (kalori != null) {
        setState(() {
          _gunlukKaloriler[entry.key] = kalori;
        });
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedYiyecekler = widget.yiyecekKayitlari[_selectedDay] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takvim'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_gunlukKaloriler[date] != null) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Text(
                        '${_gunlukKaloriler[date]} kcal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedYiyecekler.length,
              itemBuilder: (context, index) {
                final yiyecek = _selectedYiyecekler[index];
                return ListTile(
                  title: Text(yiyecek.isim),
                  subtitle: Text('${yiyecek.kalori} kcal - ${yiyecek.birim}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
