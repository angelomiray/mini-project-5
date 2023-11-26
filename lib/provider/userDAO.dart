import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp5/models/user.dart';

class UserDAO with ChangeNotifier {
  // Instância única da classe UserDAO
  static final UserDAO _instance = UserDAO._internal();
  final _baseUrl = 'https://mini-projeto-5-16b2c-default-rtdb.firebaseio.com/';
  final List<User> _users = [];
  late User currentUser;

  UserDAO._internal() {
    fetchUsers();
  }

  void setCurrentUser(User u) {
    currentUser = u;
  }

  factory UserDAO() {
    return _instance;
  }

  Future<void> addUser(User user) {
    final future = http.post(Uri.parse('$_baseUrl/users.json'),
        body: jsonEncode({
          "login": user.login,
          "pw": user.pw,
        }));
    return future.then((response) {
      user.setId(jsonDecode(response.body)['name']);
      _users.add(user);
      notifyListeners();
    });
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/users.json'));

    if (response.statusCode == 200) {
      _users.clear();
      if (json.decode(response.body) != null) {
        final Map<String, dynamic> data = json.decode(response.body);
        data.forEach((key, value) {
          User competitor = User.fromJson(key, value);
          _users.add(competitor);
        });
      }
      notifyListeners();
      return _users;
    } else {
      throw Exception('Falha ao carregar users');
    }
  }

  bool tryLogin(String email, String pw) {
    final result = _users.firstWhere(
        (user) => user.login == email && user.pw == User.calculateSHA256(pw),
        orElse: () => User(id: '-1', login: 'none', pw: 'none'));

    if (result.login != 'none') {
      currentUser = result;
      return true;
    }

    return false;
  }

  bool checkLogin(String login) {
    for (int i = 0; i < _users.length; ++i) {
      if (_users[i].login == login) {
        return false;
      }
    }

    return true;
  }
}
