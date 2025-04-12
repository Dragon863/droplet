import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:droplet/utils/log.dart';
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
  late Map cachedPfpVersions;
  late Map cachedNames;

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
      // Normal on first API call after cold start
      _jwt = await _account.createJWT().then((Jwt jwt) => jwt.jwt);
      debugLog("JWT is null, creating new one");
      debugLog("New JWT: $_jwt");
      return _jwt!;
    }
    // Split the JWT into its three parts - header, payload, signature
    final String splitToken = _jwt!.split(".")[1]; // Payload

    final maybeValidJwt = getJsonFromJWT(splitToken);

    if ((jsonDecode(maybeValidJwt)["exp"] * 1000) <
        DateTime.now().millisecondsSinceEpoch) {
      // Appwrite uses seconds, not milliseconds, since epoch

      // JWT is expired
      debugLog("JWT is expired, creating new one");
      debugLog(
        "Original expired at ${jsonDecode(maybeValidJwt)["exp"] * 1000}, now is ${DateTime.now().millisecondsSinceEpoch}",
      );
      _jwt = await _account.createJWT().then((Jwt jwt) => jwt.jwt);
      debugLog("New JWT: $_jwt");
      return _jwt!;
    } else {
      // JWT is still valid
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

  Future<void> cachePfpVersions() async {
    final String jwtToken = await getJwt();
    final friends = await getFriends();

    List<String> userIds = [];
    for (var friend in friends) {
      userIds.add(friend["userid"]);
    }

    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/cache/get/pfp-versions'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_ids': userIds}),
    );
    cachedPfpVersions = jsonDecode(response.body);
  }

  Future<void> cacheNames() async {
    final String jwtToken = await getJwt();
    final friends = await getFriends();

    List<String> userIds = [];
    for (var friend in friends) {
      userIds.add(friend["userid"]);
    }

    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/name/get/batch'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_ids': userIds}),
    );

    cachedNames = jsonDecode(response.body);
  }

  Future<void> createEmailSession({
    required String email,
    required String password,
  }) async {
    await _account.createEmailPasswordSession(email: email, password: password);
    _currentUser = await Account(_client).get();
    OneSignal.login(_currentUser.$id);
    _status = AccountStatus.authenticated;
    await cachePfpVersions();
    await cacheNames();
  }

  String getPfpUrl(String userId) {
    if (cachedPfpVersions.containsKey(userId)) {
      return "https://appwrite.danieldb.uk/v1/storage/buckets/${DropletConfig.profileBucketId}/files/$userId/view?project=${DropletConfig.appwriteProjectId}&version=${cachedPfpVersions[userId]}";
    }
    return "https://appwrite.danieldb.uk/v1/storage/buckets/${DropletConfig.profileBucketId}/files/$userId/view?project=${DropletConfig.appwriteProjectId}&version=0";
  }

  Future<void> incrementPfpVersion() async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/cache/update/pfp-version'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (response.statusCode != 200) {
      throw "Error incrementing pfp version";
    }
    await cachePfpVersions();
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
    if (jsonBody["error"] != null) {
      return jsonBody["error"];
    } else if (jsonBody["message"] != null) {
      return jsonBody["message"];
    } else {
      // Shouldn't happen
      return "Operation complete";
    }
  }

  Future<String> sendFriendRequest(String userId) async {
    final String jwtToken = await getJwt();

    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/friend-requests'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'receiver_id': userId}),
    );
    return humanResponse(response.body);
  }

  Future<void> blockUser(String userId) async {
    final String jwtToken = await getJwt();
    final response = await http.post(
      Uri.parse('${DropletConfig.apiUrl}/api/block'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'blocked_id': userId}),
    );
    if (response.statusCode != 201) {
      throw "Error blocking user";
    }
    return;
  }

  Future<bool> respondToFriendRequest(
    String userId,
    bool accept,
    int id,
  ) async {
    final String jwtToken = await getJwt();
    final response = await http.put(
      Uri.parse('${DropletConfig.apiUrl}/api/friend-requests/${id.toString()}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'action': accept ? 'accept' : 'decline'}),
    );
    return response.statusCode == 200;
  }

  Future<List> getFriends() async {
    final String jwtToken = await getJwt();
    List<Map> friends = [];

    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/friends'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    for (final friend in jsonDecode(response.body)) {
      if (friend["receiver_id"] == user!.$id) {
        friends.add({
          "userid": friend["sender_id"],
          "status": friend["status"],
          "id": friend["id"],
          "created_at": friend["created_at"],
          "updated_at": friend["updated_at"],
        });
      } else {
        friends.add({
          "userid": friend["receiver_id"],
          "status": friend["status"],
          "id": friend["id"],
          "created_at": friend["created_at"],
          "updated_at": friend["updated_at"],
        });
      }
    }
    return friends;
  }

  Future<List> getFriendRequests() async {
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/friend-requests?status=pending'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    return jsonDecode(response.body);
  }

  Future<String> getName(String userId) async {
    if (cachedNames.containsKey(userId)) {
      return cachedNames[userId].toString();
    }
    final String jwtToken = await getJwt();
    final response = await http.get(
      Uri.parse('${DropletConfig.apiUrl}/api/name/get/$userId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    return jsonDecode(response.body)["name"];
  }

  User? get user => _currentUser;
  Account? get account => _account;
}
