import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/map_screen.dart';
import '../utils/location_util.dart';

import 'package:http/http.dart' as http;

class AddressForm extends StatefulWidget {
  final Function(String, LatLng) onAddressEntered;

  AddressForm(this.onAddressEntered);

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _addressController = TextEditingController();
  LatLng? _selectedPosition;

  void _searchAddress() async {
    final enteredAddress = _addressController.text;
    
    final apiKey = 'AIzaSyCVofpmhGlUw5zBskGF6XvGUlik8Rtt0jY';

    //tive que ativar a opção GEOCODING API no google cloud

    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$enteredAddress&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        final double lat = location['lat'];
        final double lng = location['lng'];

        setState(() {
          _selectedPosition = LatLng(lat, lng);
        });
      } else {        
        print('Geocoding request failed with status: ${data['status']}');
      }
    } else {      
      print('HTTP request failed with status code: ${response.statusCode}');
    }
  }

  void _confirmAddress() {
    if (_selectedPosition != null) {
      widget.onAddressEntered(_addressController.text, _selectedPosition!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informe o endereço:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Endereço'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _searchAddress,
            child: Text('Confirmar busca'),
          ),
          SizedBox(height: 16.0),
          Text(
            'Resultado da busca:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          // Exiba o resultado da busca
          Text(_selectedPosition != null
              ? 'Lat: ${_selectedPosition!.latitude}, Lng: ${_selectedPosition!.longitude}'
              : 'Sem resultado'),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: _confirmAddress,
              child: Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}
