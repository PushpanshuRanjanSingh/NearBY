import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

String otpGenerate() {
  Random random = new Random();
  int otp = random.nextInt(999999);
  return otp.toString();
}

Future<String> sendMail(String otp, String email) async {
  Map data = {
    "otp": otp,
    "subject": "Your One Time Password [$otp]",
    "email": email
  };
  String body = json.encode(data);
  http.Response response = await http.post(
    'https://nearbyme.tk/sendmail/',
    body: body,
    headers: {"Content-Type": "application/json"},
  );
  print(response.body);
  return (response.body);
}
