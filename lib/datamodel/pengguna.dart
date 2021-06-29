import 'dart:convert';
import 'respon.dart';

class APIBaseData {
  late Pengguna? pengguna;
  final APIResonse respon;
  
  APIBaseData({
    required this.respon,
    this.pengguna,
  });

   factory APIBaseData.fromJson(Map<String, dynamic> json) {
    return APIBaseData(
      respon: APIResonse(code: json["code"], pesanStatus: json["message"]),
      pengguna: Pengguna.fromJson(jsonDecode(json["user"]))
    );
  }
}

class BasePengguna {
    late int? id;
    late String? username;
    late String? discriminator;
    
    BasePengguna({
      this.id,
      this.username,
      this.discriminator,
    }); 

    factory BasePengguna.fromJson(Map<String, dynamic> json) {
    return BasePengguna(
      id: json["userId"] ?? 0,
      username: json["username"] ?? "",
      discriminator: json["discriminator"] ?? "0000"
    );
  }
}

class Pengguna {
  late BasePengguna? user;
  late String? email;
  late String? password;
  late String? token;
   
  Pengguna({
      this.user,
      this.email,
      this.password,
      this.token,
  });

  bool telahLogin() {
    return this.token != null;
  }

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
        user: BasePengguna.fromJson(json),
        email: json["email"] ?? "blumlogin@gmail.com",
        password: json["password"] ?? "",
        token: json["token"] ?? ""
    );
  }
}