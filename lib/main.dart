import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mp5/models/place.dart';
import 'package:mp5/provider/userDAO.dart';
import 'package:mp5/screens/login_screen.dart';
import 'package:mp5/screens/place_details_screen.dart';
import 'package:mp5/screens/signup_screen.dart';
import 'package:provider/provider.dart';

import 'provider/great_places.dart';
import 'screens/place_form_screen.dart';
import 'screens/places_list_screen.dart';
import 'utils/app_routes.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserDAO()),
      ChangeNotifierProvider(create: (context) => GreatPlaces()),
    ], child: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Great Places',
      theme: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.indigo,
                secondary: Colors.amber,
              )),
      home: LoginScreen(),
      routes: {
        AppRoutes.PLACE_FORM: (ctx) => PlaceFormScreen(),
        AppRoutes.LOGIN: (ctx) => LoginScreen(),
        AppRoutes.SIGNUP: (ctx) => SignupScreen(),
        AppRoutes.PLACES_LIST: (ctx) => PlacesListScreen(),
        AppRoutes.PLACE_DETAILS: (ctx) => PlaceDetailsScreen(
              place: Place(
                  id: '-1',
                  creatorId: '-1',
                  title: 'Error',
                  image: File(''),
                  phoneNumber: '(99) 99999-9999'),
            isConnected: false,),
      },
    );
  }
}
