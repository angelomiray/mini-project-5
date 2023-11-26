import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mp5/components/address_form.dart';
import '../screens/map_screen.dart';
import '../utils/location_util.dart';

class LocationInput extends StatefulWidget {
  final Function(double lat, double lng) onSelectLocation;
  final double defaultLat;
  final double defaultLng;

  LocationInput({
    required this.onSelectLocation,
    required this.defaultLat,
    required this.defaultLng,
  });

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: widget.defaultLat,
      longitude: widget.defaultLng,
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });

    widget.onSelectLocation(widget.defaultLat, widget.defaultLng);
  }

  Future<void> _getCurrentUserLocation() async {
    final locData = await Location().getLocation();
    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: locData.latitude,
      longitude: locData.longitude,
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });

    widget.onSelectLocation(locData.latitude!, locData.longitude!);
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: ((context) => MapScreen()),
      ),
    );

    if (selectedPosition == null) return;

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: selectedPosition.latitude,
      longitude: selectedPosition.longitude,
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });

    widget.onSelectLocation(
      selectedPosition.latitude,
      selectedPosition.longitude,
    );
  }

  Future<void> _openAddressFormModal(BuildContext context) async {
    String? enteredAddress = '';
    LatLng? enteredPosition;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return AddressForm((address, position) {
          setState(() {
            enteredAddress = address;
            enteredPosition = position;
          });
        });
      },
    );

    if (enteredAddress != null && enteredPosition != null) {
      final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: enteredPosition!.latitude,
        longitude: enteredPosition!.longitude,
      );

      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });

      widget.onSelectLocation(
        enteredPosition!.latitude,
        enteredPosition!.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: _previewImageUrl == null
              ? Text('Localização não informada!')
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Localização atual'),
                onPressed: _getCurrentUserLocation,
              ),
              TextButton.icon(
                icon: Icon(Icons.map),
                label: Text('Selecione no Mapa'),
                onPressed: _selectOnMap,
              ),
            ],
          ),
        ),
        TextButton.icon(
          icon: Icon(Icons.edit_location),
          label: Text('Informe o Endereço'),
          onPressed: () => _openAddressFormModal(context),
        ),
      ],
    );
  }
}
