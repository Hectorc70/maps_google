import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  late Position _currentPosition;
  late final _startAddress;
  Set<Marker> markers = {};
  late final _destinationAddress =
      "Avenida 18 oriente, 3209, Cristobal Colon, 72370";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  //Guarda  marcadores

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.from(markers),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
        ),
        button_my_location(),
      ],
    );
  }

  Widget button_my_location() {
    return Container(
        alignment: AlignmentDirectional.bottomCenter,
        child: ClipOval(
          child: Material(
            color: Colors.orange.shade100, // button color
            child: InkWell(
              splashColor: Colors.orange, // inkwell color
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.my_location),
              ),
              onTap: () async {
                final coord = await _getAddressCoordinates();

                if (coord != null) {
                  String idMarker = '(${coord.latitude}, ${coord.longitude})';

                  await _movetoPosition(
                      coord.latitude, coord.longitude, idMarker);
                }
              },
            ),
          ),
        ));
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Guarda la  posicion en la variable
        _currentPosition = position;

        print('Mi Posicion: $_currentPosition');

        _drawMark(position.latitude, position.longitude,
            '(${position.latitude}, ${position.longitude})');
        // Mueve a posicion actual
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    });
  }

  /*  _getAddress() async {
    try {
      List<Placemark> p = await (_destinationAddress);

      Placemark addressData = p[0];

      final _currentAddress =
          "${addressData.name}, ${addressData.locality}, ${addressData.postalCode}, ${addressData.country}";


      setState(() {});
    } catch (e) {
      print(e);
    }
  } */

  Future<dynamic> _getAddressCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(_destinationAddress,
          localeIdentifier: 'es_MX');

      Location coords = locations[0];

      return coords;
    } catch (e) {
      print(e);
      return null;
    }
  }

  _movetoPosition(latitude, longitude, startCoordinatesString) {
    _drawMark(latitude, longitude, startCoordinatesString);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            // Will be fetching in the next step
            latitude,
            longitude,
          ),
          zoom: 18.0,
        ),
      ),
    );
  }

  _drawMark(double latitudeM, double longitudeM, startCoordinatesString) {
    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: LatLng(latitudeM, longitudeM),
      infoWindow: InfoWindow(
        title: 'Start $startCoordinatesString',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      markers.add(startMarker);
    });
    
  }
/*   _route_two_points(){
    String startCoordinatesString = '($startLatitude, $startLongitude)';
    String destinationCoordinatesString = '($destinationLatitude, $destinationLongitude)';
  } */

}
