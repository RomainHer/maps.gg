import 'package:flutter/material.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<VideoGame, int> videoGames;
  final double distanceRange;
  final String measureUnit;

  const FilterBottomSheet(
      {super.key,
      required this.videoGames,
      required this.distanceRange,
      required this.measureUnit});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<VideoGame> selectedVideoGames = [];
  late double distance;
  late String measureUnit;

  @override
  void initState() {
    super.initState();
    distance = widget.distanceRange;
    measureUnit = widget.measureUnit;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
                child: Text("Paramètre géographique")),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(distance.toStringAsFixed(0),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
              child: Text("Date de l'événement"),
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

          /*Expanded(
          child: ListView.builder(
            itemCount: widget.videoGames.length,
            itemBuilder: (context, index) {
              final videoGameList = widget.videoGames.entries.toList();
              return CheckboxListTile(
                title: Text(
                    '${videoGameList[index].key.displayName} (${videoGameList[index].value})'),
                value: selectedVideoGames.contains(videoGameList[index].key),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedVideoGames.add(videoGameList[index].key);
                    } else {
                      selectedVideoGames.remove(videoGameList[index].key);
                    }
                  });
                },
              );
            },
          ),
        ),*/
        ],
      ),
    );
  }
}
