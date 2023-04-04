import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerLayerTournaments extends StatelessWidget {
  final List<dynamic>? coordonates;

  const MarkerLayerTournaments({super.key, required this.coordonates});

  List<Marker> getListMarkers() {
    List<Marker> markers = [];
    for (var coordonate in coordonates!) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(coordonate['lat'], coordonate['lng']),
          builder: (ctx) => const Icon(
            Icons.location_pin,
            color: Colors.red,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: getListMarkers(),
    );
  }
}
