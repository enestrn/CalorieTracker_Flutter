import 'package:flutter/material.dart';
import 'kayit_ol.dart';
import '../db/db_helper.dart';
import '../models/kullanici.dart';
import 'main_screen.dart';
import 'admin_home.dart';

class HesapGirisiSayfasi extends StatefulWidget {
  @override
  _HesapGirisiSayfasiState createState() => _HesapGirisiSayfasiState();
}

class _HesapGirisiSayfasiState extends State<HesapGirisiSayfasi> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _girisYap() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    Kullanici? kullanici = await _dbHelper.kullaniciGetir(email);
    if (kullanici != null && kullanici.sifre == password) {
      if (kullanici.rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(isAdmin: false)),
        );
      }
    } else {
      _showErrorDialog('Giriş Başarısız', 'E-posta veya şifre yanlış.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Tamam'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override //Giriş ekranının UI tasarımını oluşturma
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesap Girişi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-posta'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _girisYap,
              child: Text('Giriş'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KayitOlSayfasi()),
                );
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
