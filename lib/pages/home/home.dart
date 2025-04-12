import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:droplet/pages/home/components/prompt_card.dart';
import 'package:droplet/pages/home/components/response_card.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
          child: ListView(
            physics: ScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: PageTopBar(
                  title: 'Home',
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        customButton: Icon(
                          Icons.keyboard_arrow_down,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        buttonStyleData: ButtonStyleData(
                          overlayColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: 160,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: '1', child: Text('Item 1')),
                          DropdownMenuItem(value: '2', child: Text('Item 2')),
                          DropdownMenuItem(value: '3', child: Text('Item 3')),
                        ],
                        onChanged: (value) {
                          // Handle dropdown item selection
                        },
                      ),
                    ),
                  ),
                ),
              ),
              VerticalSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: PromptCard(
                  text:
                      '"Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit Sed"',
                ),
              ),
              VerticalSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text('Submit Answer'),
                ),
              ),
              VerticalSpacer(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: Divider(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              VerticalSpacer(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ResponseCard(
                        pfpUrl:
                            "https://lh3.googleusercontent.com/a/ACg8ocIUbyZuM0hwf9Ks5XCqmqnBYTM1QkKMYE_sPUjIjkDPJTw60Q=s83-c-mo",
                        name: "Dohn Joe",
                        response:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed etiam, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      ),
                      ResponseCard(
                        pfpUrl:
                            "https://static.independent.co.uk/2024/09/06/11/MixCollage-06-Sep-2024-11-08-AM-5516.jpg?width=120",
                        name: "Jack Black",
                        response:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed etiam, sed do eiusmod tempor ",
                      ),
                      ResponseCard(
                        pfpUrl:
                            "https://static.independent.co.uk/2024/09/06/11/MixCollage-06-Sep-2024-11-08-AM-5516.jpg?width=120",
                        name: "John Pork",
                        response:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed etiam, sed do eiusmod tempor ",
                      ),
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
