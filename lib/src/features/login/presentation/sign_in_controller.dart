import 'package:bolao_app/src/features/login/data/auth_repository.dart';
import 'package:bolao_app/src/features/login/shared/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a StateNotifier subclass using AsyncValue<void> as the state
class SignInScreenController extends StateNotifier<AsyncValue<void>> {
  //Set the initial value
  SignInScreenController({required this.authRepository})
      : super(const AsyncData(null));

  final AuthRepository authRepository;

  Future<void> signIn() async {
    // set the state to loading
    state = const AsyncLoading();

    // call `authRepository.signIn` and await for the result
    state = await AsyncValue.guard<void>(() => authRepository.signIn());
  }
}

final signInScreenControllerProvider =
    // StateNotifierProvider takes the controller class and state class as type arguments
    StateNotifierProvider.autoDispose<SignInScreenController, AsyncValue<void>>(
        (ref) {
  return SignInScreenController(
      authRepository: ref.watch(authRepositoryProvider));
});
