import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PromptCard extends StatefulWidget {
  final String bubbleId;
  const PromptCard({super.key, required this.bubbleId});

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> {
  bool sketeton = true;
  String text = "Loading... (this is a placeholder :D )";
  String? pfpUrl;
  String promptBy = "Loading...";
  bool showBottomRow = true;

  Future<void> loadPrompt() async {
    final API api = context.read<API>();
    try {
      final Prompt prompt = await api.getTodaysPrompt(widget.bubbleId);
      final PromptAssignment assignment = await api.getTodaysPromptAssignment(
        widget.bubbleId,
      );
      if (prompt.prompt == null) {
        setState(() {
          if (assignment.assignedUserId == api.userid) {
            text = "You have not chosen a prompt yet!";
          } else {
            text = "Waiting for ${assignment.displayName} to choose a prompt!";
          }
          sketeton = false;
          showBottomRow = false;
        });
        return;
      }

      setState(() {
        text = '"${prompt.prompt}"';
        sketeton = false;
        pfpUrl = assignment.profilePicture;
        promptBy = assignment.displayName;
      });
    } catch (e) {
      setState(() {
        text = e.toString();
        sketeton = false;
        showBottomRow = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPrompt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: sketeton,
      child: Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              VerticalSpacer(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
              VerticalSpacer(height: 12),
              if (showBottomRow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Prompt by ",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      promptBy,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HorizontalSpacer(width: 2),
                    if (pfpUrl != null) const SizedBox(width: 2),
                    pfpUrl != null
                        ? CircleAvatar(
                          backgroundImage: NetworkImage(pfpUrl!),
                          radius: 10,
                        )
                        : const SizedBox(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
