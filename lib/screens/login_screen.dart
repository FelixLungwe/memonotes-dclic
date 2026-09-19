import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'notes_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _authenticationFailed = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final String username = _usernameController.text.trim();

    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _authenticationFailed = true;
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _authenticationFailed = false;
    });

    try {
      final bool authenticated = await _authService.authenticate(
        username: username,
        password: password,
      );

      if (!mounted) {
        return;
      }

      if (!authenticated) {
        setState(() {
          _authenticationFailed = true;
        });

        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotesListScreen()),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _authenticationFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 56),

              const _Logo(),

              const SizedBox(height: 28),

              const Text(
                'MemoNotes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Vos idées, simplement.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 64),

              const Text(
                "Nom d'utilisateur",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _usernameController,
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  hintText: "Saisissez votre nom d'utilisateur",
                  enabledBorder: _authenticationFailed ? _errorBorder() : null,
                ),
                onChanged: (_) {
                  if (_authenticationFailed) {
                    setState(() {
                      _authenticationFailed = false;
                    });
                  }
                },
              ),

              const SizedBox(height: 26),

              const Text(
                'Mot de passe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: !_passwordVisible,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: 'Saisissez votre mot de passe',
                  enabledBorder: _authenticationFailed ? _errorBorder() : null,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },
                onChanged: (_) {
                  if (_authenticationFailed) {
                    setState(() {
                      _authenticationFailed = false;
                    });
                  }
                },
              ),

              if (_authenticationFailed) ...[
                const SizedBox(height: 8),

                const Text(
                  "Nom d'utilisateur ou mot de passe incorrect.",
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],

              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'N',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
