import 'package:bolao_app/src/api/bolao_api.dart';
import 'package:bolao_app/src/features/login/data/auth_repository.dart';
import 'package:bolao_app/src/features/login/data/storage_repository.dart';
import 'package:bolao_app/src/features/login/domain/user_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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

final tokenValidationProvider = FutureProvider.autoDispose<UserAuth?>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return authState.maybeWhen(data: (user) async {
    if (user != null) {
      final idToken = await user.getIdToken();
      return await ref.watch(authRepositoryProvider
          .select((value) => value.validateIdToken(idToken)));
    }

    return Future.value(null);
  }, orElse: () {
    return Future.value(null);
  });
});

final flutterSecureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage();
});

final storageProvider = Provider<StorageRepository>((ref) {
  return FakeStorageRepository(
      storage: ref.watch(flutterSecureStorageProvider));
});

final authValidationProvider = FutureProvider.autoDispose<bool?>((ref) {
  final userState = ref.watch(tokenValidationProvider);

  return userState.maybeWhen(data: (user) async {
    if (user != null) {
      await ref.watch(storageProvider).save(user.jwt);
      return Future.value(true);
    }

    return Future.value(false);
  }, orElse: () {
    return Future.value(false);
  });
});
