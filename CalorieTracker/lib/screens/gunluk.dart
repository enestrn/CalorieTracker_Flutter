import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/yiyecek.dart';
import 'hesap_girisi.dart';

class GunlukScreen extends StatefulWidget {
  final Map<DateTime, List<Yiyecek>> yiyecekKayitlari;

  GunlukScreen({required this.yiyecekKayitlari});

  @override
  _GunlukScreenState createState() => _GunlukScreenState();
}

class _GunlukScreenState extends State<GunlukScreen> {
  late DBHelper _dbHelper;
  List<Yiyecek> _gunlukYiyecekler = [];
  int _gunlukKalori = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    _gunlukYiyecekleriYukle(_selectedDate);
  }

  Future<void> _gunlukYiyecekleriYukle(DateTime date) async {
    final yiyecekler = await _dbHelper.gunlukYiyecekleriGetir(date);
    final kalori = await _dbHelper.getirGunlukKalori(date);

    setState(() {
      _gunlukYiyecekler = yiyecekler;
      _gunlukKalori = kalori ?? 0;
    });
  }

  void _cikisYap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HesapGirisiSayfasi()),
    );
  }

  void _tarihSec(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _gunlukYiyecekleriYukle(_selectedDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Günlük Kalori Takibi'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _tarihSec(context),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Emin misiniz?'),
                    content: Text('Çıkış yapmak istediğinizden emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Hayır'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _cikisYap();
                        },
                        child: Text('Evet'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _gunlukYiyecekler.length,
              itemBuilder: (context, index) {
                final yiyecek = _gunlukYiyecekler[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(
                      yiyecek.isim,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Kalori: ${yiyecek.kalori} kcal',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Miktar: ${yiyecek.birim}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Günlük Tüketilen Kalori: $_gunlukKalori kcal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
