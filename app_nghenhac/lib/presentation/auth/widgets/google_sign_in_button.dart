import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/service_locator.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignInService _googleSignInService = sl<GoogleSignInService>();
  bool _isLoading = false;
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    // Hủy listener khi dispose
    LanguageService.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        _currentLanguage = LanguageService.languageNotifier.value;
      });
    }
  }

  Future<void> _loadLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _googleSignInService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is signed in
          final user = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Icon(Icons.person)
                    : null,
              ),
              SizedBox(height: 8),
              Text('${LanguageService.getTextSync('welcome', _currentLanguage)}, ${user.displayName ?? LanguageService.getTextSync('User', _currentLanguage)}!'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(LanguageService.getTextSync('Sign Out', _currentLanguage)),
              ),
            ],
          );
        } else {
          // User is not signed in
          return ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.login),
            label: Text(LanguageService.getTextSync('Sign in with Google', _currentLanguage)),
          );
        }
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();
      if (userCredential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.getTextSync('Login successful', _currentLanguage))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.getTextSync('Login cancelled', _currentLanguage))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${LanguageService.getTextSync('Login error', _currentLanguage)}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await _googleSignInService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.getTextSync('Signed out successfully', _currentLanguage))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${LanguageService.getTextSync('Sign out error', _currentLanguage)}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}