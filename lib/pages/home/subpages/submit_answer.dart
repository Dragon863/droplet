import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class SubmitAnswerPage extends StatefulWidget {
  final String bubbleId;
  const SubmitAnswerPage({super.key, required this.bubbleId});

  @override
  State<SubmitAnswerPage> createState() => _SubmitAnswerPageState();
}

class _SubmitAnswerPageState extends State<SubmitAnswerPage> {
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12.0),
          child: PageTopBar(title: "Response"),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Answer",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      controller: answerController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                    ),
                    VerticalSpacer(height: 6),
                    Row(
                      children: [
                        const Spacer(),
                        FloatingActionButton(
                          onPressed: () {
                            if (answerController.text != "") {
                              Navigator.of(context).pop(answerController.text);
                            } else {
                              Navigator.of(context).pop(null);
                            }
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.keyboard_arrow_right),
                        ),
                      ],
                    ),
                    VerticalSpacer(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
