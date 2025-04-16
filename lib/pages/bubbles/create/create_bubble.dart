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
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: PageTopBar(title: "New Bubble"),
              ),
              VerticalSpacer(height: 12),
              TextFormField(
                autofocus: true,
                keyboardType: TextInputType.text,
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  hintText: "Bubble Name",
                ),
                onFieldSubmitted: (value) {
                  if (nameController.text != "") {
                    Navigator.of(context).pop(nameController.text);
                  } else {
                    Navigator.of(context).pop(null);
                  }
                },
              ),
              VerticalSpacer(height: 8),
              Row(
                children: [
                  const Spacer(),
                  FloatingActionButton(
                    onPressed: () {
                      if (nameController.text != "") {
                        Navigator.of(context).pop(nameController.text);
                      } else {
                        Navigator.of(context).pop(null);
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
