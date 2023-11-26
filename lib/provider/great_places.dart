import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:mp5/provider/userDAO.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../utils/db_util.dart';

class GreatPlaces with ChangeNotifier {
  final String _baseUrl =
      'https://mini-projeto-5-16b2c-default-rtdb.firebaseio.com/';

  List<Place> _items = [];
  List<Place> _localDBitems = [];

  //apenas itens do db local
  Future<void> loadLocalData() async {
    final dataList = await DbUtil.getData('places');
    print('here');
    _items.clear();
    _items = dataList
        .map(
          (item) => Place(
            id: item['id'],
            creatorId: item['creatorId'],
            title: item['title'],
            image: File(item['image']),
            location: PlaceLocation(
              latitude: item['latitude'],
              longitude: item['longitude'],
              address: item['address'],
            ),
            phoneNumber: item['phoneNumber'],
          ),
        )
        .toList();
    notifyListeners();
  }

  List<Place> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Place itemByIndex(int index) {
    return _items[index];
  }

  Future<void> synchronizeLocalData() {
    final lastFiveItems =
        _items.length >= 5 ? _items.sublist(_items.length - 5) : items;

    _localDBitems.clear();
    DbUtil.deleteAllItems('places');
    for (int i = 0; i < lastFiveItems.length; ++i) {
      DbUtil.insert('places', {
        'id': lastFiveItems[i].id,
        'creatorId': lastFiveItems[i].creatorId,
        'title': lastFiveItems[i].title,
        'image': lastFiveItems[i].image.path,
        'latitude': lastFiveItems[i].location!.latitude,
        'longitude': lastFiveItems[i].location!.longitude,
        'address': lastFiveItems[i].location!.address,
        'phoneNumber': lastFiveItems[i].phoneNumber,
      });
      _localDBitems.add(lastFiveItems[i]);
    }

    notifyListeners();
    return Future.value();
  }

  Future<void> savePlace(Place place, isUpdate) {
    if (isUpdate) {
      return updatePlace(place);
    } else {
      return addPlace(place);
    }
  }

  Future<void> addPlace(Place newPlace) {
    final future = http.post(Uri.parse('$_baseUrl/places.json'),
        body: jsonEncode({
          'creatorId': newPlace.creatorId,
          'title': newPlace.title,
          'image': newPlace.image.path,
          'latitude': newPlace.location!.latitude,
          'longitude': newPlace.location!.longitude,
          'address': newPlace.location!.address,
          'phoneNumber': newPlace.phoneNumber,
        }));

    return future.then((response) {
      //id -1 até atualizar neste momento
      newPlace.setId(jsonDecode(response.body)['name']);
      _items.add(newPlace);
      DbUtil.insert('places', {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'latitude': newPlace.location!.latitude,
        'longitude': newPlace.location!.longitude,
        'address': newPlace.location!.address,
        'phoneNumber': newPlace.phoneNumber,
      });

      notifyListeners();
    });
  }

  Future<void> updatePlace(Place place) {
    int index = _items.indexWhere((p) => p.id == place.id);

    if (index >= 0) {
      _items[index] = place;
      notifyListeners();
    }

    http.patch(Uri.parse('$_baseUrl/places/${_items[index].id}.json'),
        body: jsonEncode({
          'id': place.id,
          'creatorId': place.creatorId,
          'title': place.title,
          'image': place.image.path,
          'latitude': place.location!.latitude,
          'longitude': place.location!.longitude,
          'address': place.location!.address,
          'phoneNumber': place.phoneNumber,
        }));

    DbUtil.updateItem('places', place.id, {
      'id': place.id,
      'creatorId': place.creatorId,
      'title': place.title,
      'image': place.image.path,
      'latitude': place.location!.latitude,
      'longitude': place.location!.longitude,
      'address': place.location!.address,
      'phoneNumber': place.phoneNumber,
    });

    return Future.value();
  }

  void removePlace(Place place) {
    int index = _items.indexWhere((p) => p.id == place.id);
    print(index);
    if (index >= 0) {
      print('here2');
      http.delete(Uri.parse('$_baseUrl/places/${_items[index].id}.json'));
      _items.removeAt(index);
      DbUtil.deleteItem('places', place.id);
      notifyListeners();
    }
  }

  Future<List<Place>> fetchPlaces(String currentUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/places.json'));
    print('here3');
    if (response.statusCode == 200) {
      _items.clear();
      if (json.decode(response.body) != null) {
        final Map<String, dynamic> data = json.decode(response.body);
        data.forEach((key, value) {
          Place place = Place.fromJson(key, value);

          if (place.creatorId == currentUserId) {
            _items.add(place);
          }
        });
      }
      synchronizeLocalData();
      notifyListeners();
      return _items;
    } else {
      throw Exception('Falha ao carregar lugares');
    }
  }
}
