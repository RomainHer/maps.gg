import 'package:flutter/material.dart';

class FilterElement extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const FilterElement(
      {super.key,
      this.children = const [],
      this.title = "",
      this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: EdgeInsets.only(bottom: 10, right: 10, left: 10),
          tilePadding: EdgeInsets.all(0),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
          children: children,
        ),
      ],
    );
  }
}
