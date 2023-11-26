import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mp5/screens/place_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import '../provider/great_places.dart';
import '../utils/app_routes.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context, String info) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informativo'),
          content: Text(info),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Lugares'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (!isConnected) {
                await showConfirmationDialog(
                    context, 'Você está sem internet.');
              } else {
                Provider.of<GreatPlaces>(context, listen: false)
                    .synchronizeLocalData();
                await showConfirmationDialog(
                    context, 'Banco de dados local sincronizado com sucesso.');
              }

              setState(() {});
            },
            icon: Icon(Icons.sync_alt),
          ),
          IconButton(
            onPressed: () async {
              isConnected = await checkInternetConnection();

              if (isConnected) {
                await Provider.of<GreatPlaces>(context, listen: false)
                    .fetchPlaces();
              } else {
                await Provider.of<GreatPlaces>(context, listen: false)
                    .loadLocalData();
              }

              setState(() {});
            },
            icon: Icon(Icons.autorenew),
          ),
        ],
      ),
      body: isConnected
          ? FutureBuilder(
              future: Provider.of<GreatPlaces>(context, listen: false)
                  .fetchPlaces(),
              builder: (ctx, snapshot) => handlePlacesSnapshot(snapshot),
            )
          : FutureBuilder(
              future: Provider.of<GreatPlaces>(context, listen: false)
                  .loadLocalData(),
              builder: (ctx, snapshot) => handlePlacesSnapshot(snapshot),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!isConnected) {
            await showConfirmationDialog(context, 'Você está sem internet.');
          } else {
            Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      //problema: mesmo que eu desligasse o wifi, caso meus dados móveis
      //estivessem ligados (mesmo que sem internet), connectivityResult == mobile.
      //a solução foi fazer uma requisição e verificar o tempo pra fazer a requisição
      //(as vezes ele ficava tentando mesmo que sem internet).
      try {
        final timeoutDuration = const Duration(seconds: 5);
        final responseFuture = http.get(Uri.parse('https://www.google.com'));
        final timeoutResponse = await Future.any([
          responseFuture,
          Future.delayed(timeoutDuration, () {
            throw TimeoutException(
                'Timeout após ${timeoutDuration.inSeconds} segundos');
          }),
        ]);
        final response = timeoutResponse as http.Response;

        print(response);
        return response.statusCode == 200;
      } catch (e) {
        print('Erro ao fazer a requisição: $e');
        return false;
      }
    }
  }

  Widget handlePlacesSnapshot(AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Erro ao carregar os lugares'));
    }

    return Consumer<GreatPlaces>(
      child: Center(
        child: Text('Nenhum local'),
      ),
      builder: (context, greatPlaces, child) {
        if (greatPlaces.itemsCount == 0) {
          return child!;
        } else {
          return ListView.builder(
            itemCount: greatPlaces.itemsCount,
            itemBuilder: (context, index) => Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      FileImage(greatPlaces.itemByIndex(index).image),
                ),
                title: Text(greatPlaces.itemByIndex(index).title),
                subtitle:
                    Text(greatPlaces.itemByIndex(index).location!.address),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.update, color: Colors.blue),
                      onPressed: () async {
                        if (!isConnected) {
                          await showConfirmationDialog(
                              context, 'Você está sem internet.');
                        } else {
                          Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM,
                              arguments: greatPlaces.itemByIndex(index));
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (!isConnected) {
                          await showConfirmationDialog(
                              context, 'Você está sem internet.');
                        } else {
                          greatPlaces
                              .removePlace(greatPlaces.itemByIndex(index));
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaceDetailsScreen(place: greatPlaces.itemByIndex(index)),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
