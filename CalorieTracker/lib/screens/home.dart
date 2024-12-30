import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/yiyecek.dart';
import 'hesap_girisi.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool admin;
  final Function(DateTime, List<Yiyecek>) onGunlukYiyeceklerChanged;

  HomeScreen({required this.admin, required this.onGunlukYiyeceklerChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DBHelper _dbHelper;
  List<Yiyecek> _yiyecekler = [];
  List<Yiyecek> _gunlukYiyecekler = [];
  int _gunlukKalori = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    _yiyecekleriYukle();
    _gunlukYiyecekleriYukle(_selectedDate);
  }

  Future<void> _yiyecekleriYukle() async {
    final yiyecekler = await _dbHelper.yiyecekleriGetir();
    setState(() {
      _yiyecekler = yiyecekler;
    });
  }

  Future<void> _gunlukYiyecekleriYukle(DateTime date) async {
    final yiyecekler = await _dbHelper.gunlukYiyecekleriGetir(date);
    final kalori = await _dbHelper.getirGunlukKalori(date);

    setState(() {
      _gunlukYiyecekler = yiyecekler;
      _gunlukKalori = kalori ?? 0;
    });
  }

  void _gunlukKaloriHesapla() {
    setState(() {
      _gunlukKalori = _gunlukYiyecekler.fold(0, (sum, yiyecek) => sum + yiyecek.kalori);
    });
  }

  void _gunlukYiyecekEkle(Yiyecek yiyecek) {
    showDialog(
      context: context,
      builder: (context) {
        String birim = 'adet';
        int miktar = 1;
        return AlertDialog(
          title: Text('Yiyecek Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Birim'),
                value: birim,
                items: ['adet', 'gram', 'porsiyon'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    birim = newValue!;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Miktar'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  miktar = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  double katsayi = miktar / 100;
                  Yiyecek yeniYiyecek = Yiyecek(
                    isim: yiyecek.isim,
                    resim: yiyecek.resim,
                    kalori: (yiyecek.kalori * katsayi).round(),
                    karbonhidrat: (yiyecek.karbonhidrat * katsayi).round(),
                    protein: (yiyecek.protein * katsayi).round(),
                    yag: (yiyecek.yag * katsayi).round(),
                    birim: '$miktar $birim',
                    tarih: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  );
                  _gunlukYiyecekler.add(yeniYiyecek);
                  _gunlukKaloriHesapla();
                  widget.onGunlukYiyeceklerChanged(_selectedDate, _gunlukYiyecekler);
                });
                Navigator.pop(context);
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _gunlukYiyecekSil(Yiyecek yiyecek) {
    setState(() {
      _gunlukYiyecekler.remove(yiyecek);
      _gunlukKaloriHesapla();
      widget.onGunlukYiyeceklerChanged(_selectedDate, _gunlukYiyecekler);
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _gunlukYiyecekleriYukle(_selectedDate);
      });
    }
  }

  void _gunlukTamamla() async {
    // Günlük kaloriyi kaydet
    await _dbHelper.kaydetGunlukKalori(_selectedDate, _gunlukKalori);

    // Günlük yiyecekleri veritabanına kaydet
    await _dbHelper.gunlukYiyecekleriKaydet(_selectedDate, _gunlukYiyecekler);

    setState(() {
      _gunlukYiyecekler.clear();
      _gunlukKalori = 0;
    });

    widget.onGunlukYiyeceklerChanged(_selectedDate, []);

    await _gunlukYiyecekleriYukle(_selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Yiyecekler kaydedildi ve sıfırlandı.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalori Takip Uygulaması'),
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
              itemCount: _yiyecekler.length,
              itemBuilder: (context, index) {
                final yiyecek = _yiyecekler[index];
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
                    trailing: IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () => _gunlukYiyecekEkle(yiyecek),
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Emin misiniz?'),
                          content: Text('Günlük kaloriyi sıfırlamak istediğinizden emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Hayır'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _gunlukYiyecekler.clear();
                                  _gunlukKalori = 0;
                                  widget.onGunlukYiyeceklerChanged(_selectedDate, _gunlukYiyecekler);
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Evet'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Günlük Kalori Sıfırla'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _gunlukTamamla,
                  child: Text('Tamamla ve Kaydet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
