class Yiyecek {
  final int? id;
  final String isim;
  final String resim;
  final int kalori;
  final int karbonhidrat;
  final int protein;
  final int yag;
  final String birim;
  final String tarih;

  Yiyecek({
    this.id,
    required this.isim,
    required this.resim,
    required this.kalori,
    required this.karbonhidrat,
    required this.protein,
    required this.yag,
    required this.birim,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isim': isim,
      'resim': resim,
      'kalori': kalori,
      'karbonhidrat': karbonhidrat,
      'protein': protein,
      'yag': yag,
      'birim': birim,
      'tarih': tarih,
    };
  }

  factory Yiyecek.fromMap(Map<String, dynamic> map) {
    return Yiyecek(
      id: map['id'],
      isim: map['isim'],
      resim: map['resim'],
      kalori: map['kalori'],
      karbonhidrat: map['karbonhidrat'],
      protein: map['protein'],
      yag: map['yag'],
      birim: map['birim'],
      tarih: map['tarih'],
    );
  }
}
