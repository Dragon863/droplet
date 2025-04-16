import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class SubmitPromptPage extends StatefulWidget {
  final String bubbleId;
  const SubmitPromptPage({super.key, required this.bubbleId});

  @override
  State<SubmitPromptPage> createState() => _SubmitPromptPageState();
}

class _SubmitPromptPageState extends State<SubmitPromptPage> {
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12.0),
          child: PageTopBar(title: "Prompt"),
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
                    TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      controller: answerController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            "E.g. 'What's a song you love at the moment?'",
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
