import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedListView extends StatelessWidget {
  final List<FeedItem> feedItems;

  const FeedListView({Key? key, required this.feedItems}) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    return "${timeago.format(timestamp, locale: 'en_short')} ago";
  }

  Widget _buildAvatar(FeedItemUser? user) {
    if (user?.profilePicture != null) {
      return CircleAvatar(backgroundImage: NetworkImage(user!.profilePicture!));
    }
    return CircleAvatar(child: Icon(Icons.person));
  }

  @override
  Widget build(BuildContext context) {
    if (feedItems.isEmpty) {
      return Center(child: Text("No recent activity in your bubbles."));
    }

    return ListView.builder(
      itemCount: feedItems.length,
      itemBuilder: (context, index) {
        final item = feedItems[index];
        final timestampStr = _formatTimestamp(item.timestamp);
        final bubbleName = item.bubble.name ?? 'Unknown Bubble';

        switch (item.type) {
          case "prompt_submitted":
            return ListTile(
              leading: _buildAvatar(item.actorUser),
              title: Text(
                '${item.actorUser?.displayName ?? 'Someone'} submitted a prompt in $bubbleName',
              ),
              subtitle: Text(item.content ?? 'No prompt text'),
              trailing: Text(timestampStr),
              isThreeLine: true,
            );
          case "answer_submitted":
            return ListTile(
              leading: _buildAvatar(item.actorUser),
              title: Text(
                '${item.actorUser?.displayName ?? 'Someone'} answered the prompt in $bubbleName',
              ),
              subtitle: Text(item.content ?? 'No answer text'),
              trailing: Text(timestampStr),
              isThreeLine: true,
            );
          case "user_joined":
            return ListTile(
              leading: _buildAvatar(item.targetUser),
              title: Text(
                '${item.targetUser?.displayName ?? 'Someone'} joined $bubbleName',
              ),
              trailing: Text(timestampStr),
            );
          default:
            // Fallback for unknown types
            return ListTile(
              title: Text('Unknown event type: ${item.type} :/'),
              subtitle: Text('In $bubbleName'),
              trailing: Text(timestampStr),
            );
        }
      },
    );
  }
}
