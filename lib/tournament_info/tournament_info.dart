import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maps_gg/class/event.dart';
import 'package:maps_gg/tournament_info/item_list_info.dart';
import 'package:maps_gg/tournament_info/itinary_bottom_sheet.dart';
import 'package:maps_gg/tournament_info/tournament_info_state.dart';
import 'package:url_launcher/url_launcher.dart';

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
  const TournamentInfo({
    super.key,
    required this.tournamentInfoState,
    required this.updateTournamentInfoState,
  });

  final TournamentInfoState tournamentInfoState;
  final Function updateTournamentInfoState;

  @override
  State<TournamentInfo> createState() => _TournamentInfoState();

  getNumberDaysBeforeTournament(BuildContext context) {
    var daysBefore = getDifferenceInDays(
        DateTime.now(),
        DateTime.fromMillisecondsSinceEpoch(
            (tournamentInfoState.tournamentDate ?? 0) * 1000));
    var hoursAfterNextMidnight = getDifferenceInHours(
        DateTime.fromMillisecondsSinceEpoch(
            (tournamentInfoState.tournamentDate ?? 0) * 1000),
        getNextMidnight(DateTime.now()));
    var extraDays = hoursAfterNextMidnight > 0 ? 1 : 0;
    if (hoursAfterNextMidnight < 0) {
      return tr("days-before.today");
    } else if (hoursAfterNextMidnight < 24) {
      return tr("days-before.tomorrow");
    } else if (daysBefore < 7) {
      return plural("days-before.in-days", daysBefore + extraDays);
    } else if (daysBefore < 30) {
      return plural("days-before.in-weeks", daysBefore ~/ 7);
    } else if (daysBefore < 365) {
      return plural("days-before.in-months", daysBefore ~/ 30);
    } else {
      return plural("days-before.in-years", daysBefore ~/ 365);
    }
  }

  getDifferenceInDays(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays.abs();
  }

  getDifferenceInHours(DateTime date1, DateTime date2) {
    return date1.difference(date2).inHours;
  }

  getNextMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day + 1);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(Uri.encodeFull(url)))) {
      throw Exception('Could not launch $url');
    }
  }
}

class _TournamentInfoState extends State<TournamentInfo> {
  bool isTournamentLiked = false;

  @override
  Widget build(BuildContext context) {
    var tournamentDateTime = DateTime.fromMillisecondsSinceEpoch(
        (widget.tournamentInfoState.tournamentDate ?? 0) * 1000);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.tournamentInfoState.tournamentName ?? tr("no-name"),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                //Like button (not use for now)
                /*IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  hoverColor: Colors.white,
                  highlightColor: Colors.transparent,
                  color: Colors.black,
                  isSelected: isTournamentLiked,
                  selectedIcon: const Icon(Icons.favorite),
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    setState(() {
                      isTournamentLiked = !isTournamentLiked;
                    });
                  },
                ),*/
                IconButton(
                  hoverColor: Colors.white,
                  highlightColor: Colors.transparent,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  color: Colors.black,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget
                        .updateTournamentInfoState(TournamentInfoState.empty());
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  elevation: 10,
                  child: Image.network(
                    widget.tournamentInfoState.tournamentUrlImage ?? '',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 70,
                      width: 70,
                      color: Color(0xFFD8D8D8),
                    ),
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const SizedBox(
                                height: 70,
                                width: 70,
                                child: CircularProgressIndicator()),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ItemListInfo(
                          icon: Icons.place,
                          text: widget
                                  .tournamentInfoState.tournamentVenueAddress ??
                              tr("no-address"),
                        ),
                        ItemListInfo(
                          padding: const EdgeInsets.only(top: 5),
                          icon: Icons.calendar_today,
                          text:
                              "${capitalizeFirstLetterOfEachWord(DateFormat.yMMMMEEEEd(context.locale.toLanguageTag()).format(tournamentDateTime))} (${widget.getNumberDaysBeforeTournament(context)})",
                        ),
                        ItemListInfo(
                          padding: const EdgeInsets.only(top: 5),
                          icon: Icons.schedule,
                          text: DateFormat.Hm(context.locale.toLanguageTag())
                              .format(tournamentDateTime),
                        ),
                        ItemListInfo(
                          padding: const EdgeInsets.only(top: 5),
                          icon: Icons.group,
                          text: plural(
                              "attendees",
                              widget.tournamentInfoState
                                      .tournamentNumAttendees ??
                                  0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "${tr("events")} : ",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(
              maxHeight: 200, // Hauteur maximale pour votre Column
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.tournamentInfoState.tournamentEvents != null)
                    for (Event event
                        in widget.tournamentInfoState.tournamentEvents!)
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              elevation: 4,
                              child: Image.network(
                                event.videoGame.imageUrl,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 50,
                                  width: 50 * event.videoGame.imageRatio,
                                  color: Color(0xFFD8D8D8),
                                ),
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    loadingProgress == null
                                        ? child
                                        : const SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator()),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "attendees",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ).plural(event.numEntrants),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget._launchUrl(
                        widget.tournamentInfoState.tournamentUrl ?? '');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF3F7FFD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text("signup-details").tr(),
                ),
              ),
              const SizedBox(width: 10), // Add some spacing between buttons
              Expanded(
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      backgroundColor: const Color(0xFFFAFAFA),
                      builder: (BuildContext context) {
                        return ItinaryBottomSheet(
                          tournamentVenueAddress: widget
                                  .tournamentInfoState.tournamentVenueAddress ??
                              "",
                          tournamentVenueLat:
                              widget.tournamentInfoState.tournamentVenueLat ??
                                  0,
                          tournamentVenueLng:
                              widget.tournamentInfoState.tournamentVenueLng ??
                                  0,
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF3F7FFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text('itinerary').tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
