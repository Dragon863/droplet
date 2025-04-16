import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:droplet/pages/home/bubbleview.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> content = [];
  bool skeleton = true;
  Map dropdownValues = {
    "Placehldr": "0000",
    "Placeholder2": "1111",
    "Placeholdrr": "2222",
  };
  bool dropdownEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load content after the first frame is rendered to prevent context and theme issues
      _loadContent();
    });
  }

  Future<void> _loadContent() async {
    setState(() {
      content = [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        Center(
          child: SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ];
    });
    final API api = context.read<API>();
    final List<Bubble> bubbles = await api.getBubbles();
    dropdownValues = {};
    for (var bubble in bubbles) {
      dropdownValues[bubble.name] = bubble.id;
    }
    if (bubbles.isNotEmpty) {
      content = await renderBubble(bubbles[0].id, context, () async {
        await _loadContent();
      });
    } else {
      content = [
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Image.asset('assets/nocontenthome.png', height: 120, width: 120),
            Text(
              'Join a bubble in the bubbles tab!',
              style: GoogleFonts.ibmPlexMono(fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ];
      dropdownEnabled = false;
    }

    setState(() {
      skeleton = false;
    });
  }

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
                  trailing: Visibility(
                    visible: dropdownEnabled,
                    child: Padding(
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
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          items:
                              dropdownValues.entries
                                  .map(
                                    (entry) => DropdownMenuItem<String>(
                                      value: entry.value,
                                      onTap: () async {
                                        setState(() {
                                          skeleton = true;
                                        });
                                        content = [];
                                        content = await renderBubble(
                                          entry.value,
                                          context,
                                          () async {
                                            await _loadContent();
                                            setState(() {});
                                          },
                                        );
                                        setState(() {
                                          skeleton = false;
                                        });
                                      },
                                      child: Skeletonizer(
                                        enabled: skeleton,
                                        child: Text(
                                          entry.key,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ...content,
            ],
          ),
        ),
      ),
    );
  }
}
