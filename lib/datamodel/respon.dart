// BaseResponse

class APIResonse {
  late String pesanStatus;
  late int code;

  APIResonse({
    required this.code,
    required this.pesanStatus
  });

  factory APIResonse.fromJson(Map<String, dynamic> json) {
    return APIResonse(
      code: json['code'],
      pesanStatus: json['message'],
    );
  }
}

