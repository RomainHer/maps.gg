import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_gg/marker_tournament.dart';

class MarkerLayerTournaments extends StatelessWidget {
  final List<dynamic>? tournamentsData;

  const MarkerLayerTournaments({
    super.key,
    required this.tournamentsData,
  });

  List<Marker> getListMarkers() {
    List<Marker> markers = [];
    if (tournamentsData != null) {
      for (var tournament in tournamentsData!) {
        markers.add(
          Marker(
            width: 140.0,
            height: 140.0,
            point: LatLng(tournament['lat'], tournament['lng']),
            child: MarkerContentTournament(
              tournamentId: tournament['id'],
              tournamentName: tournament['name'],
              tournamentDate: tournament['date'],
              tournamentUrlImage: tournament['profileImage']['url'],
              tournamentEvents: tournament['events'],
              tournamentVenueAddress: tournament['venueAddress'],
              tournamentUrl: tournament['url'],
              tournamentNumAttendees: tournament['numAttendees'],
            ),
          ),
        );
      }
    }

    /*debugPrint("marker_layer_test");
    debugPrint(coordonates.toString());*/
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: getListMarkers(),
    );
  }
}
