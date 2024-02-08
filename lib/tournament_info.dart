import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

String capitalizeFirstLetterOfEachWord(String input) {
  List<String> words = input.split(' ');
  List<String> wordsWithCapitalizedFirstLetter = [];

  for (String word in words) {
    if (word.isNotEmpty) {
      wordsWithCapitalizedFirstLetter
          .add(word[0].toUpperCase() + word.substring(1));
    }
  }
  String result = wordsWithCapitalizedFirstLetter.join(' ');

  return result;
}

class TournamentInfo extends StatefulWidget {
  const TournamentInfo({super.key});

  @override
  State<TournamentInfo> createState() => TournamentInfoState();
}

class TournamentInfoState extends State<TournamentInfo> {
  String tournamentName = "";
  int tournamentDate = 0;
  String tournamentUrlImage = "";
  bool showTournamentInfo = false;

  late DateFormat dateFormat;

  showHideTournamentInfo(
      String tournamentName, int tournamentDate, String tournamentUrlImage) {
    setState(() {
      if (this.tournamentName != tournamentName) {
        this.tournamentName = tournamentName;
        this.tournamentDate = tournamentDate;
        this.tournamentUrlImage = tournamentUrlImage;
        showTournamentInfo = true;
      } else {
        showTournamentInfo = !showTournamentInfo;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMEEEEd('fr');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Visibility(
          visible: showTournamentInfo,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              children: [
                Text(tournamentName),
                Text(capitalizeFirstLetterOfEachWord(dateFormat.format(
                    DateTime.fromMillisecondsSinceEpoch(
                        tournamentDate * 1000)))),
                Image.network(tournamentUrlImage, width: 30, height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
