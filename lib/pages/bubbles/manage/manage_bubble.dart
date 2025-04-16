import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ManageBubblePage extends StatefulWidget {
  final List<DropletUser> members;
  final String bubbleId;
  final String bubbleName;

  const ManageBubblePage({
    super.key,
    required this.members,
    required this.bubbleId,
    required this.bubbleName,
  });

  @override
  State<ManageBubblePage> createState() => _ManageBubblePageState();
}

class _ManageBubblePageState extends State<ManageBubblePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
          child: ListView(
            physics: const ScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PageTopBar(
                  title: "Manage Bubble",
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  trailing: Icon(Icons.ios_share),
                  title: Text(
                    "Tap to share",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("And add your friends to this bubble!"),
                  tileColor: Theme.of(context).colorScheme.tertiaryContainer,
                  onTap: () async {
                    final API api = context.read<API>();
                    final Map<String, String> codeResponse = await api
                        .generateInviteCode(widget.bubbleId);
                    final String? code = codeResponse["invite_code"];
                    if (code == null) {
                      context.showErrorSnackbar("Failed to generate code");
                      return;
                    }
                    context.showSuccessSnackbar(
                      "Invite $code code copied to clipboard!",
                    );
                    Clipboard.setData(ClipboardData(text: code));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  "Members",
                  style: GoogleFonts.spaceMono(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...widget.members.map((member) {
                return ListTile(
                  leading: CircleAvatar(
                    foregroundImage: networkImgFactory(member.profilePicture),
                  ),
                  title: Text(
                    member.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Signed up ${timeago.format(member.createdAt)}",
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  "Danger Zone",
                  style: GoogleFonts.spaceMono(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.small(
                  onPressed: () async {
                    try {
                      final API api = context.read<API>();
                      final String message = await api.leaveBubble(
                        widget.bubbleId,
                      );
                      context.showSuccessSnackbar(message);
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      context.showErrorSnackbar(e.toString());
                    }
                  },
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app, size: 18),
                      HorizontalSpacer(width: 4),
                      Text("Leave Bubble", textAlign: TextAlign.start),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
