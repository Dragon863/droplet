import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class EditPromptPage extends StatefulWidget {
  final String bubbleId;
  final String prompt;
  const EditPromptPage({
    super.key,
    required this.bubbleId,
    required this.prompt,
  });

  @override
  State<EditPromptPage> createState() => _EditPromptPageState();
}

class _EditPromptPageState extends State<EditPromptPage> {
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    answerController.text = widget.prompt;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12.0),
          child: PageTopBar(title: "Edit Prompt"),
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
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text("Your edit can't be empty!"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
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
