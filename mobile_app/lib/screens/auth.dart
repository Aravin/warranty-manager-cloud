// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:warranty_manager_cloud/services/remote_config.dart';

typedef OAuthSignIn = void Function();

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'sign_in'.tr() : 'register'.tr();
}

/// Entrypoint example for various sign-in flows with Firebase.
class AuthGate extends StatefulWidget {
  // ignore: public_member_api_docs
  const AuthGate({super.key});

  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    if (!mounted) return;

    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isMacOS) {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
      };
    } else {
      authButtons = {};

      if (remoteConfig.getBool('auth_enable_google')) {
        authButtons[Buttons.GoogleDark] =
            () => _handleMultiFactorException(_signInWithGoogle);
      }
      if (remoteConfig.getBool('auth_enable_github')) {
        authButtons[Buttons.GitHub] =
            () => _handleMultiFactorException(_signInWithGitHub);
      }
      if (remoteConfig.getBool('auth_enable_fb')) {
        authButtons[Buttons.FacebookNew] =
            () => _handleMultiFactorException(_signInWithFacebook);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage('assets/logo.png'),
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mode == AuthMode.login
                          ? 'login_page'.tr()
                          : 'registration_page'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: mode == AuthMode.login
                                ? 'dont_have_account'.tr()
                                : 'you_have_account'.tr(),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: mode == AuthMode.login
                                ? 'register_now'.tr()
                                : 'login_now'.tr(),
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  mode = mode == AuthMode.login
                                      ? AuthMode.register
                                      : AuthMode.login;
                                });
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: error.isNotEmpty,
                              child: MaterialBanner(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                content: SelectableText(error),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        error = '';
                                      });
                                    },
                                    child: const Text(
                                      'dismiss',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                                contentTextStyle:
                                    const TextStyle(color: Colors.white),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: 'email'.tr(),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'required'.tr(),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'password'.tr(),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'required'.tr(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleMultiFactorException(
                                          _emailAndPassword,
                                        ),
                                child: isLoading
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(mode.label),
                              ),
                            ),
                            TextButton(
                              onPressed: _resetPassword,
                              child: const Text('forgot_password').tr(),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'or',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ).tr(),
                            const SizedBox(height: 5),
                            ...authButtons.keys.map(
                              (button) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isLoading
                                      ? Container(
                                          color: Colors.grey[200],
                                          height: 50,
                                          width: double.infinity,
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: SignInButton(
                                            button,
                                            onPressed: authButtons[button]!,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(
                                    text: mode == AuthMode.login
                                        ? 'dont_have_account'.tr()
                                        : 'you_have_account'.tr(),
                                  ),
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: mode == AuthMode.login
                                        ? 'register_now'.tr()
                                        : 'login_now'.tr(),
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          mode = mode == AuthMode.login
                                              ? AuthMode.register
                                              : AuthMode.login;
                                        });
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(text: 'or'.tr()),
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: 'continue_as_guest'.tr(),
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _anonymousAuth,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('send').tr(),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('enter_your_email').tr(),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('pass_reset_mail_sent'.tr());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldSnackbar.of(context).show('user_not_found'.tr());
        }
      } catch (e) {
        ScaffoldSnackbar.of(context).show('error_reset'.tr());
      }
    }
  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      if (!mounted) return;
      setState(() {
        error = '${e.message}';
      });
      final firstHint = e.resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) {
        return;
      }
      final auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (_) {},
        verificationFailed: print,
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
            } on FirebaseAuthException catch (e) {
              debugPrint(e.message);
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();
      try {
        if (mode == AuthMode.login) {
          await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else if (mode == AuthMode.register) {
          await _auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        }
      } finally {
        setIsLoading();
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    // Trigger the authentication flow
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn.instance.authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
    }
  }

  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      await _auth.signInWithPopup(appleProvider);
    } else {
      await _auth.signInWithProvider(appleProvider);
    }
  }

  Future<void> _signInWithGitHub() async {
    final githubProvider = GithubAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(githubProvider);
    } else {
      await _auth.signInWithProvider(githubProvider);
    }
  }

  Future<UserCredential> _signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    return _auth.signInWithCredential(facebookAuthCredential);
  }
}

Future<String?> getSmsCodeFromUser(BuildContext context) async {
  String? smsCode;

  // Update the UI - wait for the user to enter the SMS code
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('sms_code').tr(),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('sign_in').tr(),
          ),
          OutlinedButton(
            onPressed: () {
              smsCode = null;
              Navigator.of(context).pop();
            },
            child: const Text('cancel').tr(),
          ),
        ],
        content: Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            textAlign: TextAlign.center,
            autofocus: true,
          ),
        ),
      );
    },
  );

  return smsCode;
}
