import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_gg/class/videogame.dart';
import 'package:maps_gg/filters/filter_bottom_sheet.dart';
import 'package:maps_gg/filters/filter_state.dart';
import 'package:maps_gg/map/marker_layer_tournament.dart';
import 'package:maps_gg/tournament_info/tournament_info.dart';
import 'package:maps_gg/tournament_info/tournament_info_state.dart';
import 'dart:math';

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
  FilterState filterState = FilterState.empty();
  late List<dynamic> filteredTournaments;
  final TextEditingController _searchController = TextEditingController();

  //final MapController _mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);

  final double _initialZoom = 9.0;
  final double _maxZoom = 18.0;

  int getSelectedTournamentId() {
    return tournamentInfoState.tournamentId ?? 0;
  }

  bool tournamentFilter(dynamic tournament) {
    if (filterState.searchText.isNotEmpty) {
      if (!tournament['name']
              .toLowerCase()
              .contains(filterState.searchText.toLowerCase()) &&
          !tournament['venueAddress']
              .toLowerCase()
              .contains(filterState.searchText.toLowerCase())) {
        return false;
      }
    }

    if (filterState.isDistanceChanged()) {
      if (filterState.measureUnit == 'km') {
        if (tournament['distanceKm'] > filterState.distance) {
          return false;
        }
      } else {
        if (tournament['distanceMi'] > filterState.distance) {
          return false;
        }
      }
    }

    if (filterState.isVideoGamesChanged()) {
      final List<VideoGame> tournamentVideoGames = tournament['videoGames'];
      final List<VideoGame> selectedVideoGames = filterState.selectedVideoGames;
      if (selectedVideoGames.isNotEmpty) {
        if (!tournamentVideoGames
            .any((element) => selectedVideoGames.contains(element))) {
          return false;
        }
      }
    }

    if (filterState.isDateRangeChanged()) {
      final DateTimeRange? selectedDateRange = filterState.selectedDateRange;
      final DateTime tournamentDate =
          DateTime.fromMillisecondsSinceEpoch(tournament['date'] * 1000);

      if (selectedDateRange != null) {
        /*debugPrint(
            "${(tournamentDate.isBefore(selectedDateRange.start) || tournamentDate.isAfter(selectedDateRange.end))} - tournamentDate: $tournamentDate - selectedDateRange: $selectedDateRange");*/
        debugPrint("--------------------");
        debugPrint(selectedDateRange.start.toString());
        debugPrint(selectedDateRange.end.toString());
        debugPrint(tournament["date"].toString());
        debugPrint(DateFormat("dd/MM/yyyy").format(tournamentDate));

        if (tournamentDate.isBefore(selectedDateRange.start) ||
            tournamentDate
                .isAfter(selectedDateRange.end.add(Duration(days: 1)))) {
          return false;
        }
      }
    }

    if (filterState.isRangeParticipantsChanged()) {
      final maxParticipants = filterState.maxParticipants;
      final minParticipants = filterState.minParticipants;
      final int tournamentParticipants = tournament['numAttendees'];

      debugPrint("min : $minParticipants - max : $maxParticipants");
      if (maxParticipants != null && minParticipants != null) {
        int maxValue = max(maxParticipants, minParticipants);
        int minValue = min(maxParticipants, minParticipants);
        if (tournamentParticipants >= maxValue ||
            tournamentParticipants <= minValue) {
          return false;
        }
      } else if (maxParticipants != null) {
        if (tournamentParticipants >= maxParticipants) {
          return false;
        }
      } else if (minParticipants != null) {
        if (tournamentParticipants <= minParticipants) {
          return false;
        }
      }
    }

    return true;
  }

  void updateFilterState(FilterState filterState) {
    setState(() {
      this.filterState = filterState;
      updateFilteredTournaments();
    });
  }

  void updateFilteredTournaments() {
    filteredTournaments = widget.tournaments
        .where((tournament) => tournamentFilter(tournament))
        .toList();
  }

  void updateTournamentInfoState(TournamentInfoState tournamentInfoState) {
    setState(() {
      this.tournamentInfoState = tournamentInfoState;
    });
  }

  void mapEventHandler(MapEvent event) {
    if (event is MapEventMoveStart || event is MapEventTap) {
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
  void dispose() {
    _animatedMapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredTournaments = widget.tournaments;
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
              tournamentsData: filteredTournaments,
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
                          color: Color(0x33252E37),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF252E37),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                              controller: _searchController,
                              onChanged: (value) => {
                                if (value.isEmpty)
                                  setState(() {
                                    filterState.searchText = '';
                                    updateFilteredTournaments();
                                  })
                              },
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
                          Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFD2767),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                setState(() {
                                  filterState.searchText =
                                      _searchController.text;
                                  updateFilterState(filterState);
                                });
                              },
                              icon: Icon(Icons.search),
                              iconSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Like button (not use for now)
                  /*Card(
                    elevation: 10,
                    color: Colors.white,
                    shape: CircleBorder(),
                    child: SizedBox(
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite,
                        ),
                      ),
                    ),
                  ),*/
                  Card(
                    elevation: 10,
                    color: Colors.white,
                    shape: filterState.isEmpty()
                        ? CircleBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 50,
                      ),
                      child: filterState.isEmpty()
                          ? IconButton(
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  backgroundColor: const Color(0xFFFAFAFA),
                                  builder: (BuildContext context) {
                                    return FilterBottomSheet(
                                      videoGames: widget.videoGames,
                                      filterState: filterState,
                                      onFilterStateChange: updateFilterState,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.filter_alt,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  backgroundColor: const Color(0xFFFAFAFA),
                                  builder: (BuildContext context) {
                                    return FilterBottomSheet(
                                      videoGames: widget.videoGames,
                                      filterState: filterState,
                                      onFilterStateChange: updateFilterState,
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF252E37),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.filter_alt,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                    if (!filterState.isEmpty())
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Text(
                                          "${filteredTournaments.length} résultats",
                                          style: TextStyle(
                                            color: Color(0xFF252E37),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  children: [
                    if (filterState.isSearchTextChanged())
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAFC9FB),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "\"${filterState.searchText}\"",
                              style: TextStyle(
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterState.searchText = '';
                                  _searchController.clear();
                                  updateFilteredTournaments();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (filterState.isDistanceChanged())
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAFC9FB),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "< ${filterState.distance.toStringAsFixed(0)}${filterState.measureUnit}",
                              style: TextStyle(
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterState.distance = 200;
                                  filterState.measureUnit = "km";
                                  updateFilteredTournaments();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (filterState.isVideoGamesChanged())
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAFC9FB),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              (filterState.selectedVideoGames.length == 1)
                                  ? filterState.selectedVideoGames[0].name
                                  : "${filterState.selectedVideoGames.length} jeux",
                              style: TextStyle(
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterState.selectedVideoGames = [];
                                  updateFilteredTournaments();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (filterState.isDateRangeChanged())
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAFC9FB),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${DateFormat('dd/MM/yy').format(filterState.selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(filterState.selectedDateRange!.end)}",
                              style: TextStyle(
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterState.selectedDateRange = null;
                                  updateFilteredTournaments();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (filterState.isRangeParticipantsChanged())
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAFC9FB),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              filterState.maxParticipants != null &&
                                      filterState.minParticipants != null
                                  ? '${filterState.minParticipants} - ${filterState.maxParticipants} inscrits'
                                  : filterState.minParticipants == null &&
                                          filterState.maxParticipants != null
                                      ? '< ${filterState.maxParticipants} inscrits'
                                      : '> ${filterState.minParticipants} inscrits',
                              style: TextStyle(
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterState.maxParticipants = null;
                                  filterState.minParticipants = null;
                                  updateFilteredTournaments();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
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
                updateTournamentInfoState: updateTournamentInfoState,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
