import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mp5/models/place.dart';
import 'package:mp5/models/user.dart';
import 'package:mp5/provider/userDAO.dart';
import 'package:provider/provider.dart';

import '../components/image_input.dart';
import '../components/location_input.dart';
import '../provider/great_places.dart';

class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key});

  @override
  _PlaceFormScreenState createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();

  Place place = Place(
      id: '-1',
      creatorId: '-1',
      title: '',
      phoneNumber: '',
      image: File(''),
      location:
          PlaceLocation(latitude: -12.9714, longitude: -38.5014, address: 'No address'));
  bool isUpdate = false;

  //deve receber a imagem
  File? _pickedImage;
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_titleController.text.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        isUpdate = true;

        final placeArg = arg as Place;
        _titleController.text = placeArg.title;
        _phoneController.text = placeArg.phoneNumber;        

        place.id = placeArg.id;
        place.creatorId = placeArg.creatorId;
        place.title = placeArg.title;
        place.phoneNumber = placeArg.phoneNumber;
        place.image = placeArg.image;
        place.location = placeArg.location;
      }
    }
  }

  void _selectImage(File? pickedImage) {
    _pickedImage = pickedImage;
  }

  void _selectLocation(double latitude, double longitude) {
    lat = latitude;
    lng = longitude;
  }

  void _submitForm(User currentUser) async {
    if (_titleController.text.isEmpty || _pickedImage == null) {
      return;
    }

    try {
      String address = await PlaceLocation.getAddress(lat, lng);

      place.title = _titleController.text;
      place.phoneNumber = _phoneController.text;
      place.image = _pickedImage!;
      place.location =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
      place.creatorId = currentUser.id;

      if (!isUpdate) {
        place.id = '-1';
      }

      Provider.of<GreatPlaces>(context, listen: false)
          .savePlace(place, isUpdate);

      Navigator.of(context).pop();
    } catch (e) {
      // Lidar com exceções, como falha na obtenção do endereço
      print('Erro ao obter o endereço: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User currentUser = Provider.of<UserDAO>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lugar'),
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Telefone',
                      ),
                    ),
                    const SizedBox(height: 25),
                    ImageInput(_selectImage),
                    const SizedBox(height: 10),
                    LocationInput(onSelectLocation: _selectLocation, defaultLat: place.location!.latitude, defaultLng: place.location!.longitude),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              _submitForm(currentUser);
            },
          ),
        ],
      ),
    );
  }
}
