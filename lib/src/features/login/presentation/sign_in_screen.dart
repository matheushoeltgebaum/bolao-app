import 'package:bolao_app/src/features/login/presentation/sign_in_controller.dart';
import 'package:bolao_app/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      signInScreenControllerProvider,
      (_, state) => state.showSnackbarOnError(context),
    );

    // watch and rebuild when the state changes
    final AsyncValue<void> state = ref.watch(signInScreenControllerProvider);

    return Scaffold(
        appBar: AppBar(title: const Text('Google Sign In')),
        body: Center(
            child: ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () =>
                  ref.read(signInScreenControllerProvider.notifier).signIn(),
          // conditionally show a CircularProgressIndicator if the state is "loading"
          child: state.isLoading
              ? const CircularProgressIndicator()
              : const Text('Sign in with Google'),
        )));
  }
}
