import 'package:flutter/material.dart';
import 'package:mp5/utils/location_util.dart';
import '../models/place.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;
  final bool isConnected;

  PlaceDetailsScreen({required this.place, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final location = LocationUtil.generateLocationPreviewImage(
        latitude: place.location!.latitude,
        longitude: place.location!.longitude);

    void _makePhoneCall(String phoneNumber) async {
      final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneCallUri)) {
        await launchUrl(phoneCallUri);
      } else {
        print('Não foi possível realizar a chamada.');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_callback),
            onPressed: () {
              _makePhoneCall(place.phoneNumber);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 200,
                      child: Image.file(place.image, fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text(
                    'Telefone:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Text(
                    place.phoneNumber,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text(
                    'Endereço:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Text(
                    place.location!.address,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              Container(
                height: 170,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: location == null || isConnected == false
                    ? const Text('Não foi possível carregar a localização!')
                    : Image.network(
                        location,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
