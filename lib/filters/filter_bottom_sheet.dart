import 'package:flutter/material.dart';
import 'package:maps_gg/filters/filter_element.dart';
import 'package:maps_gg/filters/filter_state.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<VideoGame, int> videoGames;
  final FilterState filterState;

  const FilterBottomSheet(
      {super.key, required this.videoGames, required this.filterState});

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
      });
    }
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
              FilterElement(
                initiallyExpanded: filterState.isDistanceChanged(),
                title: "Paramètre géographique",
                children: [
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
                    value: filterState.distance,
                    onChanged: (value) =>
                        setState(() => filterState.distance = value),
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
                  MultiSelectDialogField(
                    items: widget.videoGames.keys
                        .map((videoGame) => MultiSelectItem<VideoGame>(
                            videoGame,
                            "${videoGame.displayName} (${widget.videoGames[videoGame]})"))
                        .toList(),
                    initialValue: filterState.selectedVideoGames,
                    title: Text("Jeux Vidéos"),
                    buttonText: Text("Sélectionner des jeux"),
                    onConfirm: (values) {
                      setState(() {
                        filterState.selectedVideoGames = values;
                      });
                    },
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
                            ? "Du ${filterState.selectedDateRange!.start.day}/${filterState.selectedDateRange!.start.month}/${filterState.selectedDateRange!.start.year} au ${filterState.selectedDateRange!.end.day}/${filterState.selectedDateRange!.end.month}/${filterState.selectedDateRange!.end.year}"
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
                      });
                    },
                  ),
                ],
              ),
              FilterElement(
                title: "Taille de l'événement",
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
