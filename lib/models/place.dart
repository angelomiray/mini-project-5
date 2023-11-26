import 'dart:io';
import 'package:geocoding/geocoding.dart';

class PlaceLocation {
  double latitude;
  double longitude;
  String address;

  PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  static Future<String> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks[0];

      String address =
          "${place.thoroughfare}, ${place.administrativeArea}, ${place.country}";

      return address;
    } catch (e) {
      print("Erro ao obter o endereço: $e");
      return "Erro ao obter o endereço";
    }
  }
}

class Place {
  String id = '';
  String title;
  PlaceLocation? location;
  File image;
  String phoneNumber;

  Place({
    required this.id,
    required this.title,
    this.location,
    required this.image,
    required this.phoneNumber,
  });

  PlaceLocation? get getLocation => location;
  set setLocation(PlaceLocation? location) => this.location = location;

  File get getImage => image;
  set setImage(File image) => this.image = image;

  String get getPhoneNumber => phoneNumber;
  set setPhoneNumber(String phoneNumber) => this.phoneNumber = phoneNumber;

  void setId(String id) {
    this.id = id;
  }

  factory Place.fromJson(String key, Map<String, dynamic> json) {
    return Place(
      id: key,
      title: json['title'] as String,
      phoneNumber: json['phoneNumber'] as String,
      location: PlaceLocation(
          address: json['address'],
          latitude: json['latitude'],
          longitude: json['longitude']),
      image: File(json['image']),
    );
  }
}
