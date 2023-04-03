import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class MapSmash extends StatelessWidget {
  const MapSmash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps.gg"),
      ),
      body: FutureBuilder(
          future: _determinePosition(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data as String);
            } else {
              return const CircularProgressIndicator();
            }
          }),
      /*FlutterMap(
        options: MapOptions(
          center: LatLng(48.8566, 2.3522), // Coordonnées de Paris
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(48.8566, 2.3522), // Coordonnées de Paris
                builder: (ctx) => const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),*/
    );
  }
}
