// Bubble class
//
// Example from API schema:
//  {
//     "id": "string",
//     "name": "string",
//     "created_at": "2025-04-14T10:48:28.821Z"
//   }

class Bubble {
  String id;
  String name;
  DateTime createdAt;

  Bubble({required this.id, required this.name, required this.createdAt});

  factory Bubble.fromJson(Map<String, dynamic> json) {
    return Bubble(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Prompt class
//
// Example from API schema:
//  {
//   "prompt": prompt,
//   "chosen_by_user_id": chosenByUserId,
//   "date": date,
// };

class Prompt {
  String? prompt;
  String? chosenByUserId;
  DateTime date;

  Prompt({this.prompt, this.chosenByUserId, required this.date});

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      prompt: json['prompt'],
      chosenByUserId: json['chosen_by_user_id'],
      date: DateTime.parse(json['date']),
    );
  }
}

// Prompt assignment class
//
// Example from backend:
// {
//         "assigned_user_id": chosen_member.user_id,
//         "display_name": user_info.display_name if user_info else "Unknown User",
//         "profile_picture": user_info.profile_picture if user_info else None,
//         "prompt_submitted": False,
//         "date": str(today),
//     }
class PromptAssignment {
  String assignedUserId;
  String displayName;
  String? profilePicture;
  bool promptSubmitted;
  DateTime date;

  PromptAssignment({
    required this.assignedUserId,
    required this.displayName,
    this.profilePicture,
    required this.promptSubmitted,
    required this.date,
  });

  factory PromptAssignment.fromJson(Map<String, dynamic> json) {
    return PromptAssignment(
      assignedUserId: json['assigned_user_id'],
      displayName: json['display_name'],
      profilePicture: json['profile_picture'],
      promptSubmitted: json['prompt_submitted'],
      date: DateTime.parse(json['date']),
    );
  }
}

// Bubble answer class
//
// Example from backend:
//         {
//             "user_id": user.id,
//             "display_name": user.display_name,
//             "profile_picture": user.profile_picture,
//             "answer": answer.answer,
//         }

class BubbleAnswer {
  String userId;
  String displayName;
  String? profilePicture;
  String answer;

  BubbleAnswer({
    required this.userId,
    required this.displayName,
    this.profilePicture,
    required this.answer,
  });

  factory BubbleAnswer.fromJson(Map<String, dynamic> json) {
    return BubbleAnswer(
      userId: json['user_id'],
      displayName: json['display_name'],
      profilePicture: json['profile_picture'],
      answer: json['answer'],
    );
  }
}

// User class
// Example from API response:
// {
//     "id": "67f40d97900fb86184c6",
//     "profile_picture": "https://appwrite.danieldb.uk/v1/storage/buckets/profiles/files/67fe13f3b558fa0c4fd1/view?project=droplet",
//     "created_at": "2025-04-14T17:18:32.697133",
//     "display_name": "Daniel Benge"
//  }
class DropletUser {
  String id;
  String? profilePicture;
  DateTime createdAt;
  String displayName;

  DropletUser({
    required this.id,
    this.profilePicture,
    required this.createdAt,
    required this.displayName,
  });

  factory DropletUser.fromJson(Map<String, dynamic> json) {
    return DropletUser(
      id: json['id'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
      displayName: json['display_name'],
    );
  }
}

// Feed item classes

class FeedItemUser {
  final String id;
  final String? displayName;
  final String? profilePicture;

  FeedItemUser({
    required this.id,
    this.displayName,
    this.profilePicture,
  });

  factory FeedItemUser.fromJson(Map<String, dynamic> json) {
    return FeedItemUser(
      id: json['id'],
      displayName: json['display_name'],
      profilePicture: json['profile_picture'],
    );
  }
}

class FeedItemBubble {
  final String id;
  final String? name;

  FeedItemBubble({
    required this.id,
    this.name,
  });

  factory FeedItemBubble.fromJson(Map<String, dynamic> json) {
    return FeedItemBubble(
      id: json['id'],
      name: json['name'],
    );
  }
}

class FeedItem {
  final String type; // one of "prompt_submitted", "answer_submitted" or "user_joined"
  final DateTime timestamp;
  final FeedItemBubble bubble;
  final FeedItemUser? actorUser; // who created prompt/answer
  final FeedItemUser? targetUser; // who joined
  final String? content; // prompt or answer text

  FeedItem({
    required this.type,
    required this.timestamp,
    required this.bubble,
    this.actorUser,
    this.targetUser,
    this.content,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      bubble: FeedItemBubble.fromJson(json['bubble']),
      actorUser: json['actor_user'] != null
          ? FeedItemUser.fromJson(json['actor_user'])
          : null,
      targetUser: json['target_user'] != null
          ? FeedItemUser.fromJson(json['target_user'])
          : null,
      content: json['content'],
    );
  }
}