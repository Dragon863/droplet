import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class ResponseCard extends StatelessWidget {
  final String pfpUrl;
  final String name;
  final String response;
  const ResponseCard({
    super.key,
    required this.pfpUrl,
    required this.name,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          shadowColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.4),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(pfpUrl),
                      radius: 12,
                    ),
                    HorizontalSpacer(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                VerticalSpacer(height: 8),
                Text(
                  response,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
