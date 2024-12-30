import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/yiyecek.dart';

class YiyecekEkle extends StatefulWidget {
  @override
  _YiyecekEkleState createState() => _YiyecekEkleState();
}

class _YiyecekEkleState extends State<YiyecekEkle> {
  final _formKey = GlobalKey<FormState>();
  String isim = '';
  String resim = '';  // Varsayılan boş resim
  int kalori = 0;
  int karbonhidrat = 0;
  int protein = 0;
  int yag = 0;
  String birim = 'adet';
  int miktar = 0;
  final DBHelper _dbHelper = DBHelper();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yiyecek Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'İsim'),
                onSaved: (value) {
                  isim = value!;
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
                  setState(() {
                    birim = newValue!;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Miktar'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  miktar = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kalori'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  kalori = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Karbonhidrat (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  karbonhidrat = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  protein = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Yağ (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  yag = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _dbHelper.insertYiyecek(Yiyecek(
                      isim: isim,
                      resim: resim,  // Resim alanı boş geçilebilir
                      kalori: kalori,
                      karbonhidrat: karbonhidrat,
                      protein: protein,
                      yag: yag,
                      birim: '$miktar $birim',
                      tarih: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    ));
                    Navigator.pop(context);
                  }
                },
                child: Text('Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
