import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:droplet/utils/log.dart';
import 'package:droplet/utils/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:appwrite/appwrite.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:droplet/utils/config.dart';
// import 'package:shared_preferences/shared_preferences.dart';

enum AccountStatus { uninitialized, authenticated, unauthenticated }

class API extends ChangeNotifier {
  late User _currentUser;
  AccountStatus _status = AccountStatus.uninitialized;

  final Client _client = Client();
  String? _jwt;
  late Account _account;
  Map cachedNames = {};
  Map cachedPfpUrls = {};

  User get currentUser => _currentUser;
  AccountStatus get status => _status;
  String? get email => _currentUser.email;
  String? get userid => _currentUser.$id;
  Client get client => _client;

  API() {
    init();
    loadUser();
  }

  init() {
    _client
        .setEndpoint(DropletConfig.appwriteEndpoint)
        .setProject(DropletConfig.appwriteProjectId);
    _account = Account(_client);
  }

  loadUser() async {
    try {
      final User user = await _account.get();
      _currentUser = user;
      _account = Account(_client);
      _status = AccountStatus.authenticated;
      OneSignal.login(_currentUser.$id);
    } catch (e) {
      _status = AccountStatus.unauthenticated;
    }
    notifyListeners();
  }

  String getJsonFromJWT(String splitToken) {
    String normalizedSource = base64Url.normalize(splitToken);
    return utf8.decode(base64Url.decode(normalizedSource));
  }

  Future<String> getJwt() async {
    if (_jwt == null) {
      _jwt = await _account.createJWT().then((Jwt jwt) => jwt.jwt);
      debugLog("JWT is null, creating new one");
      return _jwt!;
    }
    final String splitToken = _jwt!.split(".")[1];
    final maybeValidJwt = getJsonFromJWT(splitToken);

    if ((jsonDecode(maybeValidJwt)["exp"] * 1000) <
        DateTime.now().millisecondsSinceEpoch) {
      debugLog("JWT is expired, creating new one");
      _jwt = await _account.createJWT().then((Jwt jwt) => jwt.jwt);
      return _jwt!;
    } else {
      debugLog("JWT is still valid");
      return _jwt!;
    }
  }

  Future<User?> createUser({
    required String email,
    required String password,
  }) async {
    loadUser();
    final user = await _account.create(
      userId: "unique()",
      email: email,
      password: password,
    );
    _currentUser = user;
    _status = AccountStatus.authenticated;
    await createEmailSession(email: email, password: password);
    notifyListeners();
    loadUser();
    return _currentUser;
  }

  Future<void> createEmailSession({
    required String email,
    required String password,
  }) async {
    await _account.createEmailPasswordSession(email: email, password: password);
    _currentUser = await Account(_client).get();
    OneSignal.login(_currentUser.$id);
    _status = AccountStatus.authenticated;
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSessions();
      _jwt = null;
      _status = AccountStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    _currentUser = await account!.get();
  }

  String humanResponse(String body) {
    final jsonBody = jsonDecode(body);
    if (jsonBody["detail"] != null) {
      // FastAPI errors use "detail". idk if this is a good idea!
      if (jsonBody["detail"] is String) {
        return jsonBody["detail"];
      } else if (jsonBody["detail"] is List && jsonBody["detail"].isNotEmpty) {
        return jsonBody["detail"][0]["msg"] ?? "Invalid input";
      }
    } else if (jsonBody["message"] != null) {
      return jsonBody["message"];
    }
    return "Operation complete";
  }

  bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Future<String?> getName(String userId, {bool changeForYou = true}) async {
    if (changeForYou && userId == userid) {
      return "You";
    }
    if (cachedNames.containsKey(userId)) {
      return cachedNames[userId].toString();
    }
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/user/name/$userId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting name: ${response.body}");
      throw humanResponse(response.body);
    }
    cachedNames[userId] = jsonDecode(response.body)["name"];
    return jsonDecode(response.body)["name"];
  }

  Future<String> setName(String name) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/user/name?name=$name'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error setting name: ${response.body}");
      throw humanResponse(response.body);
    }
    cachedNames[userid!] = name;
    loadUser();
    return humanResponse(response.body);
  }

  Future<String?> getPfpUrl(String userId) async {
    if (cachedPfpUrls.containsKey(userId)) {
      return cachedPfpUrls[userId].toString();
    }
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/user/pfp/$userId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting pfp: ${response.body}");
      throw humanResponse(response.body);
    }
    cachedPfpUrls[userId] = jsonDecode(response.body);
    return jsonDecode(response.body);
  }

  Future<Bubble> createBubble(String name) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/bubbles'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );
    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error creating bubble: ${response.body}");
      throw humanResponse(response.body);
    }
    return Bubble.fromJson(jsonDecode(response.body));
  }

  Future<List<Bubble>> getBubbles() async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/bubbles'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting bubbles: ${response.body}");
      throw humanResponse(response.body);
    }
    final List<Bubble> bubbles = [];
    final List<dynamic> jsonBody = jsonDecode(response.body);
    for (var bubble in jsonBody) {
      bubbles.add(Bubble.fromJson(bubble));
    }
    return bubbles;
  }

  Future<String> leaveBubble(String bubbleId) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/leave"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error leaving bubble: ${response.body}");
      throw humanResponse(response.body);
    }
    return humanResponse(response.body);
  }

  // deprecated: now I'm using joinBubbleWithCode instead!
  // Future<bool> joinBubble(String bubbleId) async {
  //   final String jwtToken = await getJwt();
  //   final response = await http.post( // Changed to POST
  //     Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/join"),
  //     headers: {
  //       'Authorization': 'Bearer $jwtToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (!isSuccessResponse(response.statusCode)) {
  //     debugLog("Error joining bubble by ID: ${response.body}");
  //     throw humanResponse(response.body);
  //   }
  //   return true;
  // }

  Future<Map<String, String>> generateInviteCode(String bubbleId) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/invite-code"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error generating invite code: ${response.body}");
      throw humanResponse(response.body);
    }
    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    return {
      'invite_code': jsonBody['invite_code'].toString(),
      'expires_at': jsonBody['expires_at'].toString(),
    };
  }

  Future<String> joinBubbleWithCode(String inviteCode) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/join/$inviteCode"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error joining bubble with code: ${response.body}");
      throw humanResponse(response.body);
    }
    return humanResponse(response.body);
  }

  Future<bool> submitBubbleAnswer(String bubbleId, String answer) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse(
        "${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/answer?answer=${Uri.encodeComponent(answer)}",
      ),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error submitting answer: ${response.body}");
      throw humanResponse(response.body);
    }
    return true;
  }

  Future<List<BubbleAnswer>> getBubbleAnswers(String bubbleId) async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/answers"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting answers: ${response.body}");
      throw humanResponse(response.body);
    }
    final List<BubbleAnswer> answers = [];
    final List<dynamic> jsonBody = jsonDecode(response.body);
    for (var answer in jsonBody) {
      answers.add(BubbleAnswer.fromJson(answer));
    }
    return answers;
  }

  Future<Prompt> getTodaysPrompt(String bubbleId) async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/prompt"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting prompt: ${response.body}");
      throw humanResponse(response.body);
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    return Prompt.fromJson(jsonBody);
  }

  Future<bool> setTodaysPrompt(String bubbleId, String prompt) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse(
        "${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/prompt?prompt=${Uri.encodeComponent(prompt)}",
      ),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error setting prompt: ${response.body}");
      throw humanResponse(response.body);
    }
    return true;
  }

  Future<void> pfpUpdated(String url) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse(
        "${DropletConfig.apiUrl}/api/v1/user/pfp?pfp_url=${Uri.encodeComponent(url)}",
      ),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error updating pfp: ${response.body}");
      throw humanResponse(response.body);
    }
    if (url.toLowerCase() != "none") {
      cachedPfpUrls[userid!] = url;
    } else {
      cachedPfpUrls.remove(userid!); // Remove if set to none
    }
    notifyListeners(); // Notify listeners after cache update
  }

  Future<PromptAssignment> getTodaysPromptAssignment(String bubbleId) async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse(
        "${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/prompt-assignment",
      ),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting prompt assignment: ${response.body}");
      throw humanResponse(response.body);
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    return PromptAssignment.fromJson(jsonBody);
  }

  Future<List<DropletUser>> getBubbleMembers(String bubbleId) async {
    final String jwtToken = await getJwt();

    final response = await http.get(
      Uri.parse("${DropletConfig.apiUrl}/api/v1/bubbles/$bubbleId/members"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting bubble members: ${response.body}");
      throw humanResponse(response.body);
    }

    final List<DropletUser> members = [];
    final List<dynamic> jsonBody = jsonDecode(response.body);
    for (var member in jsonBody) {
      members.add(DropletUser.fromJson(member));
    }
    return members;
  }

  Future<List<FeedItem>> getUserFeed() async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/user/feed'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error getting user feed: ${response.body}");
      throw humanResponse(response.body);
    }

    final List<FeedItem> feedItems = [];
    final List<dynamic> jsonBody = jsonDecode(response.body);
    for (var item in jsonBody) {
      feedItems.add(FeedItem.fromJson(item));
    }
    return feedItems;
  }

  Future<void> closeAccount() async {
    final String jwtToken = await getJwt();
    final response = await http.delete(
      Uri.parse('${DropletConfig.apiUrl}/api/v1/user/close_account'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (!isSuccessResponse(response.statusCode)) {
      debugLog("Error closing account: ${response.body}");
      throw humanResponse(response.body);
    }
    _status = AccountStatus.unauthenticated;
    _jwt = null;
    cachedNames.clear();
    cachedPfpUrls.clear();
    notifyListeners();
    OneSignal.logout();
  }

  Future<void> onboardComplete() async {
    final Preferences prefs = await account!.getPrefs();
    prefs.data["onboarded"] = true;
    await account!.updatePrefs(prefs: prefs.data);
  }

  User? get user => _currentUser;
  Account? get account => _account;
}
