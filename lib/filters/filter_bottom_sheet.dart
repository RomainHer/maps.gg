import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_gg/filters/filter_element.dart';
import 'package:maps_gg/filters/filter_state.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<VideoGame, int> videoGames;
  final FilterState filterState;
  final Function(FilterState) onFilterStateChange;

  const FilterBottomSheet({
    super.key,
    required this.videoGames,
    required this.filterState,
    required this.onFilterStateChange,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterState filterState;

  @override
  void initState() {
    super.initState();
    filterState = widget.filterState;
  }

  // Convertit un index en puissance de 2
  int _indexToPower(int index) => (1 << index); // équivalent à 2^index

// Convertit une valeur en label
  String _getLabel(double index) {
    if (index == 0) {
      return "0";
    }
    return _indexToPower(index.toInt()).toString();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: filterState.selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Sélectionnez une plage de dates',
    );

    if (pickedRange != null) {
      setState(() {
        filterState.selectedDateRange = pickedRange;
        widget.onFilterStateChange(filterState);
      });
    }
  }

  void _showMultiSelect(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: widget.videoGames.keys
              .map((videoGame) =>
                  MultiSelectItem(videoGame, videoGame.displayName))
              .toList(),
          initialValue: filterState.selectedVideoGames,
          onConfirm: (values) {
            setState(() {
              filterState.selectedVideoGames = values;
              widget.onFilterStateChange(filterState);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF7C7C7C),
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tous les filtres",
                      style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.bold),
                    ),
                    Visibility(
                      visible: !filterState.isEmpty(),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            filterState = FilterState.empty();
                            widget.onFilterStateChange(filterState);
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF666666),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.loop,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "réinitialiser les filtres",
                              style: TextStyle(
                                color: Color(0xFF7C7C7C),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FilterElement(
                initiallyExpanded: filterState.isDistanceChanged(),
                title: "Paramètre géographique",
                children: [
                  Text(
                    "Distance à partir de la localisation de l’appareil",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF979797),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          filterState.distance.toStringAsFixed(0),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownButton(
                        value: filterState.measureUnit,
                        items: [
                          DropdownMenuItem(
                            value: "km",
                            child: Text("km"),
                          ),
                          DropdownMenuItem(
                            value: "mi",
                            child: Text("miles"),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            filterState.measureUnit = value!;
                            if (value == "mi") {
                              filterState.distance =
                                  filterState.distance * 0.621371;
                            } else {
                              filterState.distance =
                                  filterState.distance * 1.60934;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Slider(
                    activeColor: Color(0xFF666666),
                    value: filterState.distance,
                    onChanged: (value) => setState(() {
                      filterState.distance = value;
                      widget.onFilterStateChange(filterState);
                    }),
                    min: 0,
                    max: filterState.measureUnit == "km" ? 300 : 200,
                    divisions: 30,
                    label: filterState.distance.toStringAsFixed(0),
                  ),
                ],
              ),
              FilterElement(
                initiallyExpanded: filterState.isVideoGamesChanged(),
                title: "Jeux vidéos",
                children: [
                  Visibility(
                    visible: filterState.selectedVideoGames.isNotEmpty,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 8),
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: filterState.selectedVideoGames.map((game) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 8, right: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0x663F7FFD),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  game.displayName,
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
                                      filterState.selectedVideoGames
                                          .remove(game);
                                      widget.onFilterStateChange(filterState);
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
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  /*MultiSelectChipDisplay(
                    items: filterState.selectedVideoGames
                        .map((e) => MultiSelectItem(e, e.displayName))
                        .toList(),
                    onTap: (value) {
                      setState(() {
                        filterState.selectedVideoGames.remove(value);
                        widget.onFilterStateChange(filterState);
                      });
                    },
                  ),*/
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _showMultiSelect(context),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(3, 3),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 10,
                              ),
                              child: Text(
                                "Choisir un ou plusieurs jeu(x)",
                                style: TextStyle(color: Color(0xFFA4A4A4)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 2),
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFEDEDED),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: Icon(Icons.add, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              FilterElement(
                initiallyExpanded: filterState.isDateRangeChanged(),
                title: "Dates des événements",
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        filterState.selectedDateRange != null
                            ? "Du ${DateFormat('dd/MM/yy').format(filterState.selectedDateRange!.start)} au ${DateFormat('dd/MM/yy').format(filterState.selectedDateRange!.end)}"
                            : "Sélectionnez une plage de dates",
                        style: TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDateRange(context),
                        child: Text("Choisir"),
                      ),
                    ],
                  ),
                ],
              ),
              FilterElement(
                initiallyExpanded: filterState.isRangeParticipantsChanged(),
                title: "Nombre d'inscrits",
                children: [
                  Text(
                    "Entre ${_getLabel(filterState.selectedRangeParticpants.start)} et ${_getLabel(filterState.selectedRangeParticpants.end)} inscrits",
                    style: TextStyle(fontSize: 16),
                  ),
                  RangeSlider(
                    values: filterState.selectedRangeParticpants,
                    min: 0, // Correspond à 2^0
                    max: 12, // Correspond à 2^10
                    divisions: 10,
                    labels: RangeLabels(
                      _getLabel(filterState.selectedRangeParticpants.start),
                      _getLabel(filterState.selectedRangeParticpants.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        filterState.selectedRangeParticpants = values;
                        widget.onFilterStateChange(filterState);
                      });
                    },
                  ),
                ],
              ),
              /*FilterElement(
                title: "Taille de l'événement",
                children: [],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
