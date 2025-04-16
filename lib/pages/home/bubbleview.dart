import 'package:droplet/pages/home/components/prompt_card.dart';
import 'package:droplet/pages/home/components/submit_btn.dart';
import 'package:droplet/pages/home/layout/response_card_view.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

Future<List<Widget>> renderBubble(
  String bubbleId,
  BuildContext context,
  Function? refreshFunction,
) async {
  return [
    VerticalSpacer(height: 12),
    Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: PromptCard(bubbleId: bubbleId, key: Key("${bubbleId}promptcard")),
    ),
    VerticalSpacer(height: 12),
    SubmitButton(
      bubbleId: bubbleId,
      onPromptChosen: (prompt) async {
        if (refreshFunction != null) {
          await refreshFunction();
        }
      },
      key: Key("${bubbleId}submitbutton"),
    ),
    VerticalSpacer(height: 24),
    Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
      child: Divider(color: Theme.of(context).colorScheme.onTertiaryContainer),
    ),
    VerticalSpacer(height: 24),
    Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ResponseCardView(
        bubbleId: bubbleId,
        key: Key("${bubbleId}responsecardview"),
      ),
    ),
  ];
}
