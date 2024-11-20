import 'package:flutter/material.dart';
import 'package:maps_gg/class/videogame.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<VideoGame, int> videoGames;

  const FilterBottomSheet({super.key, required this.videoGames});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<VideoGame> selectedVideoGames = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
