import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> searchSuggestions = [];
  bool showSuggestions = false;

  //final MapController _mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);

  final double _initialZoom = 9.0;
  final double _maxZoom = 18.0;

  int getSelectedTournamentId() {
    return tournamentInfoState.tournamentId ?? 0;
  }

  List<dynamic> _filterTournamentsByName(String query) {
    if (query.isEmpty) {
      return [];
    }
    final queryLower = query.toLowerCase();
    final filtered = widget.tournaments
        .where((tournament) =>
            tournament['name']?.toString().toLowerCase().contains(queryLower) ??
            false)
        .take(8)
        .toList();
    return filtered;
  }

  void _onSuggestionSelected(dynamic tournament) {
    setState(() {
      showSuggestions = false;
      _searchController.clear();
      _searchFocusNode.unfocus();
    });

    // Center map on tournament, offset so the marker appears in the upper half
    // of the screen (above the detail card that occupies the bottom 50%)
    final screenHeight = MediaQuery.of(context).size.height;
    final offsetPixels = screenHeight / 6;
    const crs = Epsg3857();
    final tournamentPoint = crs.latLngToPoint(
      LatLng(tournament['lat'], tournament['lng']),
      14.0,
    );
    final shiftedPoint = Point<double>(
      tournamentPoint.x,
      tournamentPoint.y + offsetPixels,
    );
    final offsetCenter = crs.pointToLatLng(shiftedPoint, 14.0);
    _animatedMapController.animateTo(
      dest: offsetCenter,
      zoom: 14.0,
      duration: const Duration(milliseconds: 500),
    );

    // Open tournament detail
    updateTournamentInfoState(
      TournamentInfoState(
        true,
        tournament['id'],
        tournament['name'] ?? '',
        tournament['date'] ?? 0,
        tournament['profileImage'] != null
            ? tournament['profileImage']['url']
            : '',
        tournament['events'] ?? [],
        tournament['venueAddress'] ?? '',
        tournament['lat'] ?? 0,
        tournament['lng'] ?? 0,
        tournament['url'] ?? '',
        tournament['numAttendees'] ?? 0,
      ),
    );
  }

  bool tournamentFilter(dynamic tournament) {
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
        showSuggestions = false;
        _searchFocusNode.unfocus();
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

  void toggleLanguage() {
    if (context.locale == Locale('fr')) {
      context.setLocale(Locale('en'));
    } else {
      context.setLocale(Locale('fr'));
    }
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredTournaments = widget.tournaments;
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && showSuggestions) {
        setState(() {
          showSuggestions = false;
        });
      }
    });
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.all(2),
                        elevation: 10,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      searchSuggestions = [];
                                      showSuggestions = false;
                                    } else {
                                      searchSuggestions =
                                          _filterTournamentsByName(value);
                                      showSuggestions =
                                          _searchFocusNode.hasFocus &&
                                              searchSuggestions.isNotEmpty;
                                    }
                                  });
                                },
                                onTap: () {
                                  if (_searchController.text.isNotEmpty &&
                                      searchSuggestions.isNotEmpty) {
                                    setState(() {
                                      showSuggestions = true;
                                    });
                                  }
                                },
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  disabledBorder: InputBorder.none,
                                  hintText: tr('search'),
                                  border: OutlineInputBorder(
                                      gapPadding: 0,
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: double.infinity,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFD2767),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
                    //Filter button
                    Card(
                      margin: const EdgeInsets.all(2),
                      elevation: 10,
                      color: Colors.white,
                      shape: filterState.isEmpty()
                          ? CircleBorder()
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: double.infinity,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF252E37),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.filter_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!filterState.isEmpty())
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: 8, left: 5),
                                      child: Text(
                                        "x-results",
                                        style: TextStyle(
                                          color: Color(0xFF252E37),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ).plural(filteredTournaments.length),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    //Location button
                    SizedBox(
                      height: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          margin: const EdgeInsets.all(2),
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
                      ),
                    ),
                    //Language button
                    SizedBox(
                      height: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          margin: const EdgeInsets.all(2),
                          elevation: 10,
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: GestureDetector(
                            onTap: toggleLanguage,
                            child: Center(
                              child: Text(
                                context.locale == Locale('fr')
                                    ? '🇫🇷'
                                    : '🇬🇧',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 5),
                child: Wrap(
                  children: [
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
        if (showSuggestions && searchSuggestions.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 10,
            right: 10,
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: searchSuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E5E5),
                  ),
                  itemBuilder: (context, index) {
                    final tournament = searchSuggestions[index];
                    return InkWell(
                      onTap: () => _onSuggestionSelected(tournament),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament['name'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (tournament['venueAddress'] != null &&
                                tournament['venueAddress']
                                    .toString()
                                    .isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  tournament['venueAddress'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
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
        ),
      ],
    );
  }
}
