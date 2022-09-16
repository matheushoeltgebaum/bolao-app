import 'package:bolao_app/src/features/login/data/auth_repository.dart';
import 'package:bolao_app/src/features/login/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authValidationProvider);

    return authState.maybeWhen(
        data: (isValid) {
          return isValid != null && isValid
              ? const AccountScreen()
              : const SignInScreen();
        },
        orElse: () => const SignInScreen());
  }
}
