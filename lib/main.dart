import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MemoNotesApp());
}

class MemoNotesApp extends StatelessWidget {
  const MemoNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoNotes',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const LoginScreen(),
    );
  }
}
