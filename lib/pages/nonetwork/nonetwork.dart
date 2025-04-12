import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class NoNetworkPage extends StatelessWidget {
  const NoNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
          child: ListView(
            physics: ScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: PageTopBar(title: 'No Network'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const BodyText(
                  text:
                      'It seems you are not connected to the internet. Please check your connection and try again.',
                ),
              ),
              VerticalSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/");
                  },
                  child: ButtonText(text: 'Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
