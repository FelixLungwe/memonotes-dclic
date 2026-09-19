class AuthService {
  static const String demoUsername = 'memonotes';
  static const String demoPassword = 'Memo@2026';

  Future<bool> authenticate({
    required String username,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return username.trim() == demoUsername &&
        password == demoPassword;
  }
}
