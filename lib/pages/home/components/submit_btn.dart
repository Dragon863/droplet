import 'package:droplet/pages/home/subpages/edit_answer.dart';
import 'package:droplet/pages/home/subpages/edit_prompt.dart';
import 'package:droplet/pages/home/subpages/submit_answer.dart';
import 'package:droplet/pages/home/subpages/submit_prompt.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/models.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PromptMode {
  static const choose = PromptMode._("choose");
  static const editPrompt = PromptMode._("editPrompt");
  static const submit = PromptMode._("submit");
  static const editAnswer = PromptMode._("editAnswer");
  static const none = PromptMode._("none");

  final String value;

  const PromptMode._(this.value);

  @override
  String toString() {
    return value;
  }
}

class SubmitButton extends StatefulWidget {
  final String bubbleId;
  final Function(String)? onPromptChosen;

  const SubmitButton({super.key, required this.bubbleId, this.onPromptChosen});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool loading = true;
  String buttonText = "Button Text";
  PromptMode mode = PromptMode.none;
  bool btnEnabled = true;

  Future<void> loadButton() async {
    final API api = context.read<API>();
    final PromptAssignment assignment = await api.getTodaysPromptAssignment(
      widget.bubbleId,
    );
    if (assignment.assignedUserId == api.userid) {
      if (assignment.promptSubmitted) {
        setState(() {
          loading = false;
          buttonText = "Edit Prompt";
          mode = PromptMode.editPrompt;
        });
      } else {
        setState(() {
          loading = false;
          buttonText = "Choose Prompt";
          mode = PromptMode.choose;
        });
      }
    } else {
      final List<BubbleAnswer> answers = await api.getBubbleAnswers(
        widget.bubbleId,
      );
      if (answers.isNotEmpty) {
        final String? originalText =
            answers
                .where((answer) => answer.userId == api.user!.$id)
                .first
                .answer;
        if (originalText != null) {
          setState(() {
            loading = false;
            buttonText = "Edit Answer";
            mode = PromptMode.editAnswer;
          });
          return;
        }
      }
      if (!assignment.promptSubmitted) {
        setState(() {
          btnEnabled = false;
        });
        return;
      } else {
        setState(() {
          loading = false;
          buttonText = "Submit Answer";
          mode = PromptMode.submit;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadButton();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child:
          btnEnabled
              ? Skeletonizer(
                enabled: loading,
                child: FloatingActionButton(
                  onPressed: () async {
                    if (mode == PromptMode.submit) {
                      final String? text = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18.0),
                          ),
                        ),
                        builder:
                            (context) =>
                                SubmitAnswerPage(bubbleId: widget.bubbleId),
                      );
                      if (text != null) {
                        final API api = context.read<API>();
                        await api.submitBubbleAnswer(widget.bubbleId, text);
                        if (widget.onPromptChosen != null) {
                          widget.onPromptChosen!(text);
                        }
                      }
                    } else if (mode == PromptMode.choose) {
                      final String? text = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18.0),
                          ),
                        ),
                        builder:
                            (context) =>
                                SubmitPromptPage(bubbleId: widget.bubbleId),
                      );
                      if (text != null) {
                        final API api = context.read<API>();
                        await api.setTodaysPrompt(widget.bubbleId, text);
                        if (widget.onPromptChosen != null) {
                          widget.onPromptChosen!(text);
                        }
                      }
                    } else if (mode == PromptMode.editAnswer) {
                      final API api = context.read<API>();
                      final List<BubbleAnswer> answers = await api
                          .getBubbleAnswers(widget.bubbleId);

                      try {
                        final originalText =
                            answers
                                .where(
                                  (answer) => answer.userId == api.user!.$id,
                                )
                                .first
                                .answer;
                        final String? text = await showModalBottomSheet<String>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18.0),
                            ),
                          ),
                          builder:
                              (context) => EditAnswerPage(
                                bubbleId: widget.bubbleId,
                                answer: originalText,
                              ),
                        );
                        if (text != null) {
                          final API api = context.read<API>();
                          await api.submitBubbleAnswer(widget.bubbleId, text);
                          if (widget.onPromptChosen != null) {
                            widget.onPromptChosen!(text);
                          }
                        }
                      } on StateError {
                        context.showErrorSnackbar(
                          "Something went horribly wrong :/",
                        );
                        return;
                      }
                    } else if (mode == PromptMode.editPrompt) {
                      final API api = context.read<API>();
                      final String currentPrompt =
                          (await api.getTodaysPrompt(widget.bubbleId)).prompt!;
                      final String? text = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18.0),
                          ),
                        ),
                        builder:
                            (context) => EditPromptPage(
                              bubbleId: widget.bubbleId,
                              prompt: currentPrompt,
                            ),
                      );
                      if (text != null) {
                        await api.setTodaysPrompt(widget.bubbleId, text);
                        if (widget.onPromptChosen != null) {
                          widget.onPromptChosen!(text);
                        }
                      }
                    }
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(buttonText),
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
