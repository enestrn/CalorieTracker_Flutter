import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/kullanici.dart';

class KayitOlSayfasi extends StatefulWidget {
  @override
  _KayitOlSayfasiState createState() => _KayitOlSayfasiState();
}

class _KayitOlSayfasiState extends State<KayitOlSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DBHelper();

  String _isim = '';
  String _email = '';
  String _sifre = '';
  String _rol = 'user';

  void _kayitOl() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Kullanici yeniKullanici = Kullanici(
        isim: _isim,
        email: _email,
        sifre: _sifre,
        rol: _rol,
      );
      await _dbHelper.insertKullanici(yeniKullanici);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'İsim'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen isminizi girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _isim = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-posta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-postanızı girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _sifre = value!;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Rol'),
                value: _rol,
                items: ['admin', 'user'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _rol = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _kayitOl,
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
