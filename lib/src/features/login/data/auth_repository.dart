import 'dart:convert';
import 'dart:io';

import 'package:bolao_app/src/api/bolao_api.dart';
import 'package:bolao_app/src/features/login/domain/user_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRepository {
  // emits a new value every time the authentication state changes
  Stream<User?> authStateChanges();

  Future<void> signIn();

  Future<void> signOut();

  Future<bool?> validateIdToken(String idToken);
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
  Future<bool?> validateIdToken(String idToken) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    };
    final body = <String, String>{'idToken': idToken};

    final userAuth = await _postRequestAndRetrieveData(
        uri: api.firebaseAuth(),
        headers: headers,
        body: body,
        builder: (data) => UserAuth.fromJson(data));

    if (userAuth.jwt != '') {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: userAuth.jwt);

      return Future.value(true);
    }

    return Future.value(false);
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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  GoogleSignIn googleClientSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  return GoogleAuthRepository(
      googleClientSignIn: googleClientSignIn,
      api: BolaoAPI(),
      client: http.Client());
});

final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

final authValidationProvider = FutureProvider.autoDispose<bool?>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return authState.maybeWhen(data: (user) async {
    if (user != null) {
      final idToken = await user.getIdToken();
      return await ref.read(authRepositoryProvider).validateIdToken(idToken);
    }

    return Future.value(false);
  }, orElse: () {
    return Future.value(false);
  });
});
