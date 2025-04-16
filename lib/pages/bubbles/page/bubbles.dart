import 'package:droplet/pages/bubbles/create/create_bubble.dart';
import 'package:droplet/pages/bubbles/join/join_bubble.dart';
import 'package:droplet/pages/bubbles/page/components/bubble_card.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BubblesPage extends StatefulWidget {
  const BubblesPage({super.key});

  @override
  State<BubblesPage> createState() => _BubblesPageState();
}

class _BubblesPageState extends State<BubblesPage> {
  final List<Widget> bubbles = [];
  bool isExpanded = false;

  Future<void> loadBubbles() async {
    final API api = context.read<API>();
    final List<Bubble> bubbleList = await api.getBubbles();

    if (bubbleList.isEmpty) {
      setState(() {
        bubbles.add(
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                "No bubbles yet, create or join one!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      });
      return;
    } else {
      for (var bubble in bubbleList) {
        setState(() {
          bubbles.add(
            BubbleCard(
              bubbleId: bubble.id,
              name: bubble.name,
              createdAt: bubble.createdAt,
              key: Key("${bubble.id}bubblecard"),
              onRefresh: () async {
                bubbles.clear();
                await loadBubbles();
                setState(() {});
              },
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadBubbles();
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
                padding: const EdgeInsets.all(8.0),
                child: PageTopBar(title: "Bubbles"),
              ),
              const VerticalSpacer(height: 12),
              ...bubbles,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Theme.of(context).colorScheme.brightness == Brightness.light
                ? Color.fromARGB(255, 68, 48, 97)
                : Theme.of(context).colorScheme.primary,
        onPressed: showFabOptions,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }

  Future<void> showFabOptions() async {
    final source = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Create or Join Bubble?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("Create New"),
                leading: Icon(Icons.add),
                onTap: () {
                  Navigator.of(context).pop("create");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              ListTile(
                title: const Text("Join Existing"),
                leading: Icon(Icons.group_add_outlined),
                onTap: () {
                  Navigator.of(context).pop("join");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (source == "create") {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        isDismissible: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        builder: (_) {
          return CreateBubblePage();
        },
      ).then((value) async {
        final API api = context.read<API>();
        await api.createBubble(value);
        bubbles.clear();
        await loadBubbles();
        setState(() {});
      });
    } else if (source == "join") {
      final bool? success = await joinBubble(context);
      if (success == true) {
        bubbles.clear();
        await loadBubbles();
        setState(() {});
      }
    }
  }
}
