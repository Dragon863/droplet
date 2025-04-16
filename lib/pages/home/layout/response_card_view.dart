import 'package:droplet/pages/home/components/response_card.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ResponseCardView extends StatefulWidget {
  final String bubbleId;
  const ResponseCardView({super.key, required this.bubbleId});

  @override
  State<ResponseCardView> createState() => _ResponseCardViewState();
}

class _ResponseCardViewState extends State<ResponseCardView> {
  bool loading = true;
  List<Widget> responses = [
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
      name: "Jack Hack",
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
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadData();
    });
  }

  Future<void> loadData() async {
    final API api = context.read<API>();
    responses = [];
    final List<BubbleAnswer> answers = await api.getBubbleAnswers(
      widget.bubbleId,
    );
    if (answers.isEmpty) {
      setState(() {
        loading = false;
        responses = [
          Row(
            children: [
              const HorizontalSpacer(width: 8),
              const Icon(Icons.sentiment_dissatisfied),
              const HorizontalSpacer(width: 4),
              Text(
                "No responses yet! Check back later.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ];
      });
      return;
    }
    final List<ResponseCard> newResponses = [];
    for (var answer in answers) {
      try {
        newResponses.add(
          ResponseCard(
            pfpUrl: answer.profilePicture,
            name: answer.displayName,
            response: answer.answer,
          ),
        );
      } catch (e) {
        context.showErrorSnackbar("Error loading responses");
      }
    }
    setState(() {
      loading = false;
      responses = newResponses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Skeletonizer(enabled: loading, child: Row(children: responses)),
    );
  }
}
