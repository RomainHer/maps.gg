import 'package:flutter/material.dart';

class FilterElement extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FilterElement({super.key, this.children = const [], this.title = ""});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: EdgeInsets.all(10),
          tilePadding: EdgeInsets.all(0),
          shape: Border.all(style: BorderStyle.none),
          title: Row(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18),
                  ),
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
