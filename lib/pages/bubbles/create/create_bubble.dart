import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';

class CreateBubblePage extends StatefulWidget {
  const CreateBubblePage({super.key});

  @override
  State<CreateBubblePage> createState() => _CreateBubblePageState();
}

class _CreateBubblePageState extends State<CreateBubblePage> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.0, left: 12.0),
            child: PageTopBar(title: "Bubble Name"),
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
                        keyboardType: TextInputType.text,
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          hintText: "Bubble Name",
                        ),
                      ),
                      VerticalSpacer(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          FloatingActionButton(
                            key: const Key("createBubbleButtonStage2"),
                            onPressed: () {
                              if (nameController.text != "") {
                                Navigator.of(context).pop(nameController.text);
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
      ),
    );
  }
}
