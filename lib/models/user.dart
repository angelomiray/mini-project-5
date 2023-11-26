import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:mp5/models/place.dart';

class User {
  String id;
  final String login;
  final String pw;
  List<Place> places = [];

  User({required this.id, required this.login, required this.pw});

  void setId(String key) {
    id = key;
  }

  static String calculateSHA256(String input) {
    Uint8List bytes = Uint8List.fromList(utf8.encode(input));
    Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  factory User.fromJson(String key, Map<String, dynamic> json) {
    return User(
      id: key,
      login: json['login'],
      pw: json['pw'],
    );
  }
}
