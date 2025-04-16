import 'package:droplet/pages/bubbles/manage/manage_bubble.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class BubbleCard extends StatefulWidget {
  final String bubbleId;
  final String name;
  final DateTime createdAt;
  final Function onRefresh;

  const BubbleCard({
    super.key,
    required this.bubbleId,
    required this.name,
    required this.createdAt,
    required this.onRefresh,
  });

  @override
  State<BubbleCard> createState() => _BubbleCardState();
}

class _BubbleCardState extends State<BubbleCard> {
  bool loading = true;
  String createdAgoText = '';
  String numberOfMembersText = '';
  List<DropletUser> bubbleMembers = [];

  Future<void> loadSubtext() async {
    final API api = context.read<API>();
    final List<DropletUser> members = await api.getBubbleMembers(
      widget.bubbleId,
    );
    bubbleMembers = members;
    numberOfMembersText = members.length.toString();
    createdAgoText = timeago.format(widget.createdAt, locale: 'en_short');
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSubtext();
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final bool shouldRefresh = await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ManageBubblePage(
                    bubbleId: widget.bubbleId,
                    members: bubbleMembers,
                    bubbleName: widget.name,
                  ),
            ),
          );
          if (shouldRefresh) {
            widget.onRefresh();
          }
        },
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.spaceMono(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Skeletonizer(
                          enabled: loading,
                          child: Text(
                            "$numberOfMembersText ${numberOfMembersText == '1' ? 'member' : 'members'}, created $createdAgoText ago",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
