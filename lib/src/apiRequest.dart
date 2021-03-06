import 'dart:convert';

import 'package:http/http.dart' as httpreq;
import '../datamodel/pengguna.dart';

Map<int, String> errorAlasan = {
  400:
      "Kesalahan struktur, update versi terbaru atau tunggu maintenance untuk melanjutkan",
  401: "Akun tidak ditemukan",
  403:
      "Dilarang untuk login, update versi terbaru atau tunggu maintenance untuk melanjutkan",
  404:
      "Server tidak ditemukan, update versi terbaru atau tunggu maintenance untuk melanjutkan",
  500:
      "Server kesalahan internal, update versi terbaru atau tunggu maintenance untuk melanjutkan",
  502:
      "Server tidak dapat diakses, update versi terbaru atau tunggu maintenance untuk melanjutkan",
  503: "Server sedang maintenance"
};

Future<APIBaseData> login(String email, String password) async {
  final response = await httpreq.post(Uri.parse('https://letyra.tk/login'),
      body: {"email": email, "pw": password});

  if (response.statusCode == 200) {
    return APIBaseData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Alasan: ' + (errorAlasan[response.statusCode] ?? "Tidak diketahui"));
  }
}

Future<bool> gantiNama(String namaBaru, String token) async {
  
  final response = await httpreq.put(Uri.parse('https://letyra.tk/api/account'),
      body: {"newUsername": namaBaru}, headers: {"authorization": "token $token"});
  if (response.statusCode == 201) {
    return true;
  } else {
    throw Exception(
        'Alasan: ' + (errorAlasan[response.statusCode] ?? "Tidak diketahui"));
  }
}
