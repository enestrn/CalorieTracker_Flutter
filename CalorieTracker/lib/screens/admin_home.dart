import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/yiyecek.dart';
import 'hesap_girisi.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late DBHelper _dbHelper;
  List<Yiyecek> _yiyecekler = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    _yiyecekleriYukle();
  }

  Future<void> _yiyecekleriYukle() async {
    final yiyecekler = await _dbHelper.yiyecekleriGetir();
    setState(() {
      _yiyecekler = yiyecekler;
    });
  }

  void _yiyecekEkle() {
    showDialog(
      context: context,
      builder: (context) {
        String isim = '';
        String resim = '';
        int kalori = 0;
        int karbonhidrat = 0;
        int protein = 0;
        int yag = 0;
        String birim = 'adet';
        int miktar = 0;

        return AlertDialog(
          title: Text('Yiyecek Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'İsim'),
                onChanged: (value) {
                  isim = value;
                },
              ),
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
                  birim = newValue!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Miktar'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  miktar = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kalori'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  kalori = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Karbonhidrat (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  karbonhidrat = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  protein = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Yağ (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  yag = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _dbHelper.insertYiyecek(Yiyecek(
                  isim: isim,
                  resim: resim,
                  kalori: kalori,
                  karbonhidrat: karbonhidrat,
                  protein: protein,
                  yag: yag,
                  birim: '$miktar $birim',
                  tarih: '',
                ));
                _yiyecekleriYukle();
                Navigator.pop(context);
              },
              child: Text('Ekle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _cikisYap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HesapGirisiSayfasi()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Anasayfa'),
        actions: [
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
          ElevatedButton(
            onPressed: _yiyecekEkle,
            child: Text('Yiyecek Ekle'),
          ),
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
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.yiyecekSil(yiyecek.id!);  // null olamayacağını belirtmek için '!' kullanıyoruz
                        _yiyecekleriYukle();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}