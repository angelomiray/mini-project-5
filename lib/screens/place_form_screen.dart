import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mp5/models/place.dart';
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
      title: '',
      phoneNumber: '',
      image: File(''),
      location:
          PlaceLocation(latitude: 0, longitude: 0, address: 'No address'));
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
        _selectImage(placeArg.image);
        _selectLocation(
            placeArg.location!.latitude, placeArg.location!.longitude);        

        place.id = placeArg.id;
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

  void _submitForm() async {
    if (_titleController.text.isEmpty || _pickedImage == null) {
      return;
    }

    String address = 'address';

    address = await PlaceLocation.getAddress(lat, lng);

    place.title = _titleController.text;
    place.phoneNumber = _phoneController.text;
    place.image = _pickedImage!;
    place.location =
        PlaceLocation(latitude: lat, longitude: lng, address: address);

    if (!isUpdate) {
      place.id = '-1';
    }

    Provider.of<GreatPlaces>(context, listen: false).savePlace(place, isUpdate);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                    LocationInput(_selectLocation),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Colors.black,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
