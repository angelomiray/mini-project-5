import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mp5/models/place.dart';
import 'package:mp5/screens/place_details_screen.dart';
import 'package:provider/provider.dart';

import 'provider/great_places.dart';
import 'screens/place_form_screen.dart';
import 'screens/places_list_screen.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GreatPlaces(),
      child: MaterialApp(
        title: 'Great Places',
        theme: ThemeData().copyWith(
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: Colors.indigo,
                  secondary: Colors.amber,
                )),
        home: PlacesListScreen(),
        routes: {
          AppRoutes.PLACE_FORM: (ctx) => PlaceFormScreen(),
          AppRoutes.PLACE_DETAILS: (ctx) => PlaceDetailsScreen(place: Place(id: '-1', title: 'Error', image: File(''), phoneNumber: '(99) 99999-9999'),),
        },
      ),
    );
  }
}
