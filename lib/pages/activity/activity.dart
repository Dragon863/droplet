import 'package:droplet/pages/activity/activity_list.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Widget> activity = [];

  Future<void> loadFeed() async {
    setState(() {
      activity = [
        Skeletonizer(
          child: Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text("Activity"),
              subtitle: Text("Loading..."),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
      ];
    });
    final API api = context.read<API>();
    final List<FeedItem> feed = await api.getUserFeed();
    if (feed.isEmpty) {
      setState(() {
        activity = [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Image.asset('assets/noactivity.png', height: 120, width: 120),
                const VerticalSpacer(height: 6),
                Center(
                  child: Text(
                    "No activity yet!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      });
      return;
    } else {
      setState(() {
        activity = [FeedListView(feedItems: feed)];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final API api = context.read<API>();

    return Scaffold(
      body: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PageTopBar(title: "Activity"),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: api.getUserFeed(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error loading feed: ${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        Image.asset(
                          'assets/noactivity.png',
                          height: 120,
                          width: 120,
                        ),
                        const VerticalSpacer(height: 6),
                        Center(
                          child: Text(
                            "No activity yet!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return FeedListView(feedItems: snapshot.data!);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
