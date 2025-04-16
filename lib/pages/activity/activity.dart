import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
            child: ListView(
              physics: ScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PageTopBar(title: "Activity"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
