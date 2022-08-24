import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: dotenv.env['GOOGLE_CLIENT_ID'],
  scopes: <String>[
    'email',
    'profile',
  ],
);

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State createState() => SignInState();
}

class SignInState extends State<SignIn> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });

      if (_currentUser != null) {
        _validateGoogleToken(_currentUser!);
      }
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _validateGoogleToken(GoogleSignInAccount user) async {
    final GoogleSignInAuthentication auth = await _currentUser!.authentication;
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = {'idToken': auth.idToken};

    try {
      final http.Response response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}auth/google'),
          headers: headers,
          body: json.encode(body));

      if (response.statusCode != 200) {
        setState(() {
          _contactText = 'Could not validate Google Token.';
          print(
              'Status code: ${response.statusCode} response: ${response.body}');
        });
        return;
      }

      final dynamic data = json.decode(response.body);
      setState(() {
        if (data != null) {
          _contactText = 'Token JWT: ${data['jwt']}';
        } else {
          _contactText = 'Could not generate token JWT';
        }
      });
    } catch (exception) {
      print(exception);
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;

    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          Text(_contactText),
          ElevatedButton(
              onPressed: _handleSignOut, child: const Text('SIGN OUT'))
        ],
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text('You are not currently signed in.'),
            ElevatedButton(
                onPressed: _handleSignIn, child: const Text('SIGN IN'))
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Google Sign In')),
        body: ConstrainedBox(
            constraints: const BoxConstraints.expand(), child: _buildBody()));
  }
}
