import 'package:bolao_app/src/features/login/presentation/sign_in_controller.dart';
import 'package:bolao_app/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

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
        appBar: AppBar(title: const Text('Login')),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SignInButton(Buttons.Google,
              text: 'Fazer login com o Google',
              onPressed: state.isLoading
                  ? () {}
                  : () => ref
                      .read(signInScreenControllerProvider.notifier)
                      .signIn())
        ])));
  }
}
