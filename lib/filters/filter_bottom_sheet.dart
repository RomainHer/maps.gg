import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    filterState = widget.filterState;
    _minController = TextEditingController(text: "");
    _maxController = TextEditingController(text: "");
    if (filterState.minParticipants != null) {
      _minController.text = filterState.minParticipants.toString();
    }
    if (filterState.maxParticipants != null) {
      _maxController.text = filterState.maxParticipants.toString();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _validateMin(String value) {
    int? min = int.tryParse(value);

    setState(() {
      if (min == null) {
        _minController.text = "";
      } else {
        _minController.text = min.toString();
      }
      _minController.selection = TextSelection.fromPosition(
        TextPosition(offset: _minController.text.length),
      );
      filterState.minParticipants = min;
      widget.onFilterStateChange(filterState);
    });
  }

  void _validateMax(String value) {
    int? max = int.tryParse(value);

    setState(() {
      if (max == null) {
        _maxController.text = "";
      } else {
        _maxController.text = max.toString();
      }
      _maxController.selection = TextSelection.fromPosition(
        TextPosition(offset: _maxController.text.length),
      );
      filterState.maxParticipants = max;
      widget.onFilterStateChange(filterState);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: filterState.selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: tr("select-date-range"),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Color(0xFFAFC9FB),
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3F7FFD),
              secondary: Color(0xFFAFC9FB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                overlayColor: Color(0x50606060),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                overlayColor: Color(0x50606060),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                overlayColor: Color(0x50606060),
              ),
            ),
          ),
          child: child!,
        );
      },
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
          title: Text("select-games").tr(),
          listType: MultiSelectListType.CHIP,
          selectedColor: Color(0xFF898989),
          selectedItemsTextStyle: TextStyle(color: Colors.black),
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
                      "all-filters",
                      style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.bold),
                    ).tr(),
                    Visibility(
                      visible: !filterState.isEmpty(),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            filterState = FilterState.empty();
                            _minController.text = "";
                            _maxController.text = "";
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
                              "reset-filters",
                              style: TextStyle(
                                color: Color(0xFF7C7C7C),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FilterElement(
                initiallyExpanded: filterState.isDistanceChanged(),
                title: tr('geographic-parameter'),
                children: [
                  Text(
                    "distance-device-location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF979797),
                    ),
                  ).tr(),
                  Container(
                    margin: EdgeInsets.only(top: 10),
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
                            horizontal: 20,
                          ),
                          child: Text(
                            filterState.distance.toStringAsFixed(0),
                            style: TextStyle(
                              color: Color(0xFF3F7FFD),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 2, top: 2, bottom: 2),
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
                          child: DropdownButton(
                            isDense: true,
                            underline: SizedBox(),
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
                                if (value! != filterState.measureUnit) {
                                  filterState.measureUnit = value;
                                  if (value == "mi") {
                                    filterState.distance =
                                        filterState.distance * 0.621371;
                                  } else {
                                    filterState.distance =
                                        filterState.distance * 1.60934;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
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
                title: tr("video-games"),
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
                                  color: Color(0xFFAFC9FB),
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
                                "choose-games",
                                style: TextStyle(color: Color(0xFFA4A4A4)),
                              ).tr(),
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
                title: tr("tournament-dates"),
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _selectDateRange(context),
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
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.calendar_month),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 10,
                              ),
                              child: filterState.isDateRangeChanged()
                                  ? Text(
                                      "${DateFormat.yMd(context.locale.toLanguageTag()).format(filterState.selectedDateRange!.start)} - ${DateFormat.yMd(context.locale.toLanguageTag()).format(filterState.selectedDateRange!.end)}",
                                      style: TextStyle(
                                        color: Color(0xFF3F7FFD),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "select-dates",
                                      style: TextStyle(
                                        color: Color(0xFFA4A4A4),
                                      ),
                                    ).tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              FilterElement(
                maintainState: true,
                initiallyExpanded: filterState.isRangeParticipantsChanged(),
                title: tr("number-of-attendees"),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
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
                        child: TextField(
                          onChanged: _validateMin,
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            hintText: tr('minimum'),
                            hintStyle: TextStyle(color: Color(0xFFA4A4A4)),
                            border: OutlineInputBorder(
                                gapPadding: 0, borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.all(8),
                            isDense: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "&",
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF666666)),
                        ),
                      ),
                      Container(
                        width: 120,
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
                        child: TextField(
                          onChanged: _validateMax,
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            hintText: tr('maximum'),
                            hintStyle: TextStyle(color: Color(0xFFA4A4A4)),
                            border: OutlineInputBorder(
                                gapPadding: 0, borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.all(8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
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
