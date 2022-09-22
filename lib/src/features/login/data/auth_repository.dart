import 'dart:convert';
import 'dart:io';

import 'package:bolao_app/src/api/bolao_api.dart';
import 'package:bolao_app/src/features/login/domain/user_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

abstract class AuthRepository {
  // emits a new value every time the authentication state changes
  Stream<User?> authStateChanges();

  Future<void> signIn();

  Future<void> signOut();

  Future<UserAuth?> validateIdToken(String idToken);
}

class GoogleAuthRepository implements AuthRepository {
  GoogleAuthRepository(
      {required this.api,
      required this.client,
      required this.googleClientSignIn});

  final BolaoAPI api;
  final http.Client client;
  final GoogleSignIn googleClientSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<void> signIn() async {
    try {
      //Realiza a autenticação com a Google
      final googleUser = await googleClientSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      await _auth.signInWithCredential(credential);
    } catch (error) {
      print(error);
      throw 'Could not sign in with Google';
    }
  }

  @override
  Future<void> signOut() async {
    await googleClientSignIn.disconnect();
    await _auth.signOut();
  }

  @override
  Future<UserAuth?> validateIdToken(String idToken) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    };
    final body = <String, String>{'idToken': idToken};

    return _postRequestAndRetrieveData(
        uri: api.firebaseAuth(),
        headers: headers,
        body: body,
        builder: (data) => UserAuth.fromJson(data));
  }

  Future<T> _postRequestAndRetrieveData<T>(
      {required Uri uri,
      required Map<String, String>? headers,
      required Object? body,
      required T Function(dynamic data) builder}) async {
    try {
      final response =
          await client.post(uri, headers: headers, body: json.encode(body));
      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          return builder(data);
        case 401:
          throw 'Invalid API key';
        case 404:
          throw 'Resource not found';
        default:
          throw 'Unknown Error';
      }
    } on SocketException catch (_) {
      throw 'No Internet connection';
    }
  }
}
