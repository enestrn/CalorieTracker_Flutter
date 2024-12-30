class Kullanici {
  final int? id;
  final String isim;
  final String email;
  final String sifre;
  final String rol;

  Kullanici({
    this.id,
    required this.isim,
    required this.email,
    required this.sifre,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'rol': rol,
    };
  }

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    return Kullanici(
      id: map['id'],
      isim: map['isim'],
      email: map['email'],
      sifre: map['sifre'],
      rol: map['rol'],
    );
  }
}
