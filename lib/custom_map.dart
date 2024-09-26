import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_gg/marker_layer_tournament.dart';
import 'package:maps_gg/tournament_info.dart';
import 'package:maps_gg/tournament_info_state.dart';

class CustomMap extends StatefulWidget {
  final Position location;
  final List<dynamic> tournaments;
  final PopupController popupController;

  const CustomMap(
      {super.key,
      required this.location,
      required this.tournaments,
      required this.popupController});

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  TournamentInfoState tournamentInfoState = TournamentInfoState.empty();

  void updateTournamentInfoState(TournamentInfoState tournamentInfoState) {
    setState(() {
      this.tournamentInfoState = tournamentInfoState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(widget.location.latitude,
                widget.location.longitude), // Coordonnées de Paris
            initialZoom: 8.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            onTap: (_, __) => widget.popupController.hideAllPopups(),
          ),
          children: [
            TileLayer(
              tileProvider: CancellableNetworkTileProvider(),
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayerTournaments(
              updateTournamentInfoState: updateTournamentInfoState,
              tournamentsData: widget.tournaments,
              popupController: widget.popupController,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(
                      widget.location.latitude, widget.location.longitude),
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.blue,
                  ),
                ),
              ],
            )
          ],
        ),
        Card(
          child: Visibility(
            visible: tournamentInfoState.isTournamentSelected,
            child: TournamentInfo(
              tournamentInfoState: tournamentInfoState,
            ),
          ),
        ),
      ],
    );
  }
}
