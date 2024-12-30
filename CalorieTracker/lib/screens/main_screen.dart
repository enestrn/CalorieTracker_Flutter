import 'package:flutter/material.dart';
import 'home.dart';
import 'gunluk.dart';
import 'takvim.dart';
import '../models/yiyecek.dart';

class MainScreen extends StatefulWidget {
  final bool isAdmin;

  MainScreen({required this.isAdmin});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Yiyecek>> _yiyecekKayitlari = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateGunlukYiyecekler(DateTime date, List<Yiyecek> gunlukYiyecekler) {
    setState(() {
      _yiyecekKayitlari[date] = gunlukYiyecekler;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(admin: widget.isAdmin, onGunlukYiyeceklerChanged: _updateGunlukYiyecekler),
      GunlukScreen(yiyecekKayitlari: _yiyecekKayitlari),
      TakvimScreen(yiyecekKayitlari: _yiyecekKayitlari),

    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Yiyecekler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Günlük',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey, //
        selectedLabelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        onTap: _onItemTapped,
      ),
    );
  }
}
