import 'package:flutter/material.dart';
import 'package:mp5/provider/userDAO.dart';
import 'package:mp5/utils/app_routes.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Places for People',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserDAO usersProvider = Provider.of<UserDAO>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Places for People'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adicione sua logo aqui
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEDq_qHP-QnixCNLIwQ30DIxiMp5n5GyvHlA&usqp=CAU',
              height: 100,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Login',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (usersProvider.tryLogin(
                    _loginController.text, _pwController.text)) {
                  Navigator.of(context).pushNamed(AppRoutes.PLACES_LIST, arguments: usersProvider.currentUser);
                }
              },
              child: Text('Entrar'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.SIGNUP);
              },
              child: Text('Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
