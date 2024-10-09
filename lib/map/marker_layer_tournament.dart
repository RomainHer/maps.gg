import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_gg/map/marker_tournament.dart';

class MarkerLayerTournaments extends StatelessWidget {
  final List<dynamic>? tournamentsData;
  final PopupController popupController;
  final Function updateTournamentInfoState;
  final Function getSelectedTournamentId;

  const MarkerLayerTournaments({
    super.key,
    required this.tournamentsData,
    required this.popupController,
    required this.updateTournamentInfoState,
    required this.getSelectedTournamentId,
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
              tournamentId: tournament['id'] ?? -1,
              tournamentName: tournament['name'] ?? '',
              tournamentDate: tournament['date'] ?? 0,
              tournamentUrlImage: tournament['profileImage'] != null
                  ? tournament['profileImage']['url']
                  : '',
              tournamentEvents: tournament['events'] ?? [],
              tournamentVenueLat: tournament['lat'] ?? 0,
              tournamentVenueLng: tournament['lng'] ?? 0,
              tournamentVenueAddress: tournament['venueAddress'] ?? '',
              tournamentUrl: tournament['url'] ?? '',
              tournamentNumAttendees: tournament['numAttendees'] ?? 0,
              updateTournamentInfoState: updateTournamentInfoState,
              getSelectedTournamentId: getSelectedTournamentId,
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = getListMarkers();
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        spiderfyCircleRadius: 80,
        spiderfySpiralDistanceMultiplier: 2,
        circleSpiralSwitchover: 12,
        maxClusterRadius: 150,
        rotate: true,
        size: const Size(50, 50),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(50),
        maxZoom: 15,
        markers: markers,
        polygonOptions: const PolygonOptions(
            borderColor: Colors.blueAccent,
            color: Colors.black12,
            borderStrokeWidth: 3),
        /*popupOptions: PopupOptions(
            popupSnap: PopupSnap.markerTop,
            popupController: popupController,
            popupBuilder: (_, marker) => Container(
                  width: 200,
                  height: 100,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () => debugPrint('Popup tap!'),
                    child: const Text(
                      'Container popup for marker',
                    ),
                  ),
                )),*/
        builder: (context, markers) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0x3351BF51),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFF51BF51),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
