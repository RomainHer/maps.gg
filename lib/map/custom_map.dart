import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_gg/class/videogame.dart';
import 'package:maps_gg/map/filter_bottom_sheet.dart';
import 'package:maps_gg/map/marker_layer_tournament.dart';
import 'package:maps_gg/tournament_info/tournament_info.dart';
import 'package:maps_gg/tournament_info/tournament_info_state.dart';

class CustomMap extends StatefulWidget {
  const CustomMap(
      {super.key,
      required this.location,
      required this.tournaments,
      required this.popupController,
      required this.videoGames});

  final Position location;
  final PopupController popupController;
  final List<dynamic> tournaments;
  final Map<VideoGame, int> videoGames;

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> with TickerProviderStateMixin {
  TournamentInfoState tournamentInfoState = TournamentInfoState.empty();

  //final MapController _mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);

  final double _initialZoom = 9.0;
  final double _maxZoom = 18.0;

  int getSelectedTournamentId() {
    return tournamentInfoState.tournamentId ?? 0;
  }

  void updateTournamentInfoState(TournamentInfoState tournamentInfoState) {
    setState(() {
      this.tournamentInfoState = tournamentInfoState;
    });
  }

  void mapEventHandler(MapEvent event) {
    if (event is MapEventMoveStart) {
      setState(() {
        tournamentInfoState = TournamentInfoState.empty();
      });
    }
  }

  Future<void> _centerMapOnUser() async {
    _animatedMapController.centerOnPoint(
      LatLng(widget.location.latitude, widget.location.longitude),
      duration: Duration(milliseconds: 500),
      zoom: _initialZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.location.latitude,
                widget.location.longitude), // Coordonnées de Paris
            initialZoom: _initialZoom,
            maxZoom: _maxZoom,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            //onTap: (_, __) => widget.popupController.hideAllPopups(),
            onMapEvent: (evt) => mapEventHandler(evt),
          ),
          children: [
            TileLayer(
              tileProvider: CancellableNetworkTileProvider(),
              urlTemplate:
                  "https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayerTournaments(
              getSelectedTournamentId: getSelectedTournamentId,
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          color: Color(0x333F7FFD),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3F7FFD),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Card(
                  elevation: 10,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            hintText: 'Search',
                            border: OutlineInputBorder(
                                gapPadding: 0, borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.only(left: 20),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 10,
                color: Colors.white,
                shape: CircleBorder(),
                child: SizedBox(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.favorite,
                    ),
                    //padding: EdgeInsets.zero,
                    //iconSize: 10,
                  ),
                ),
              ),
              Card(
                elevation: 10,
                color: Colors.white,
                shape: CircleBorder(),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      backgroundColor: const Color(0xFFFAFAFA),
                      builder: (BuildContext context) {
                        return FilterBottomSheet(
                          videoGames: widget.videoGames,
                          distanceRange: 200.0,
                          measureUnit: "km",
                          selectedDateRange: null,
                          selectedVideoGames: [],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.filter_alt,
                  ),
                ),
              ),
              Card(
                elevation: 10,
                color: Colors.white,
                shape: CircleBorder(),
                child: IconButton(
                  onPressed: () {
                    _centerMapOnUser();
                  },
                  icon: const Icon(
                    Icons.my_location,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            color: Colors.white,
            elevation: 20,
            child: Visibility(
              visible: tournamentInfoState.isTournamentSelected,
              child: TournamentInfo(
                tournamentInfoState: tournamentInfoState,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
