import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<VideoGame, int> videoGames;
  final double distanceRange;
  final String measureUnit;
  final DateTimeRange? selectedDateRange;
  final List<VideoGame> selectedVideoGames;

  const FilterBottomSheet(
      {super.key,
      required this.videoGames,
      required this.distanceRange,
      required this.measureUnit,
      this.selectedDateRange,
      this.selectedVideoGames = const []});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<VideoGame> selectedVideoGames;
  late double distance;
  late String measureUnit;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    distance = widget.distanceRange;
    measureUnit = widget.measureUnit;
    selectedDateRange = widget.selectedDateRange;
    selectedVideoGames = widget.selectedVideoGames;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Sélectionnez une plage de dates',
    );

    if (pickedRange != null) {
      setState(() {
        selectedDateRange = pickedRange;
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
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text("Paramètre géographique"),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(distance.toStringAsFixed(0),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton(
                      value: measureUnit,
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
                          measureUnit = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Slider(
                value: distance,
                onChanged: (value) => setState(() => distance = value),
                min: 0,
                max: 300,
                divisions: 30,
                label: distance.toStringAsFixed(0),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text("Dates des événements"),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDateRange != null
                          ? "Du ${selectedDateRange!.start.day}/${selectedDateRange!.start.month}/${selectedDateRange!.start.year} au ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}/${selectedDateRange!.end.year}"
                          : "Sélectionnez une plage de dates",
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateRange(context),
                      child: Text("Choisir"),
                    ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text("Nombre de places"),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text("Jeux vidéos"),
                ),
              ),
              MultiSelectDialogField(
                items: widget.videoGames.keys
                    .map((videoGame) => MultiSelectItem<VideoGame>(videoGame,
                        "${videoGame.displayName} (${widget.videoGames[videoGame]})"))
                    .toList(),
                initialValue: selectedVideoGames,
                title: Text("Jeux Vidéos"),
                buttonText: Text("Sélectionner des jeux"),
                onConfirm: (values) {
                  setState(() {
                    selectedVideoGames = values;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
