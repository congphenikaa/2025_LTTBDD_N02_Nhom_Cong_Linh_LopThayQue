import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:app_nghenhac/presentation/profile/pages/profile.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/presentation/about/pages/about_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    try {
      final language = await LanguageService.getCurrentLanguage();
      if (mounted) {
        setState(() {
          _currentLanguage = language;
        });
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error loading language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final googleSignInService = sl<GoogleSignInService>();

    return Drawer(
      child: Column(
        children: [
          // Header với thông tin user
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            accountName: Text(
              currentUser?.displayName ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              currentUser?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Icon(Icons.person, size: 40, color: AppColors.primary)
                  : null,
            ),
          ),

          // Dark Mode Toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              final isDark = state == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.yellow : Colors.orange,
                ),
                title: Text(
                  LanguageService.getTextSync(
                    isDark ? 'dark_mode' : 'light_mode',
                    _currentLanguage,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeCubit>().updateTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  context.read<ThemeCubit>().updateTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              );
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              LanguageService.getTextSync('profile', _currentLanguage),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              LanguageService.getTextSync('settings', _currentLanguage),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LanguageService.getTextSync(
                      'settings_developing',
                      _currentLanguage,
                    ),
                  ),
                ),
              );
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(LanguageService.getTextSync('about', _currentLanguage)),
            onTap: () {
              Navigator.pop(context); // đóng Drawer trước
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),

          // Language Settings
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(
              LanguageService.getTextSync(
                'Language Settings',
                _currentLanguage,
              ),
            ),
            subtitle: Text(
              _currentLanguage == 'vi'
                  ? LanguageService.getTextSync('vietnamese', _currentLanguage)
                  : LanguageService.getTextSync('english', _currentLanguage),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLanguageDialog(context);
            },
          ),

          // Help
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(LanguageService.getTextSync('help', _currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LanguageService.getTextSync(
                      'help_developing',
                      _currentLanguage,
                    ),
                  ),
                ),
              );
            },
          ),

          const Divider(),

          const Spacer(),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              LanguageService.getTextSync('sign_out', _currentLanguage),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showSignOutDialog(context, googleSignInService),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LanguageService.getTextSync('about', _currentLanguage)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.getTextSync('app_music', _currentLanguage),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${LanguageService.getTextSync('version', _currentLanguage)}: 1.0.0',
              ),
              const SizedBox(height: 8),
              Text(
                LanguageService.getTextSync(
                  'music_streaming_app',
                  _currentLanguage,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Developed by: Team i',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LanguageService.getTextSync('close', _currentLanguage),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LanguageService.getTextSync('Language Settings', _currentLanguage),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.getTextSync(
                  'choose_language',
                  _currentLanguage,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LanguageService.getTextSync(
                  'change_interface_language',
                  _currentLanguage,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Vietnamese Option
              RadioListTile<String>(
                title: Row(
                  children: [
                    const Text('🇻🇳', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      LanguageService.getTextSync(
                        'vietnamese',
                        _currentLanguage,
                      ),
                    ),
                  ],
                ),
                value: 'vi',
                groupValue: _currentLanguage,
                onChanged: (String? value) {
                  if (value != null && value != _currentLanguage && mounted) {
                    _changeLanguage(context, value);
                  }
                },
                activeColor: AppColors.primary,
              ),

              // English Option
              RadioListTile<String>(
                title: Row(
                  children: [
                    const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      LanguageService.getTextSync('english', _currentLanguage),
                    ),
                  ],
                ),
                value: 'en',
                groupValue: _currentLanguage,
                onChanged: (String? value) {
                  if (value != null && value != _currentLanguage && mounted) {
                    _changeLanguage(context, value);
                  }
                },
                activeColor: AppColors.primary,
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LanguageService.getTextSync(
                          'interface_will_update',
                          _currentLanguage,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LanguageService.getTextSync('close', _currentLanguage),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    // Store context reference early
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Save the new language
      await LanguageService.saveLanguage(languageCode);

      // Update current language only if widget is still mounted
      if (mounted) {
        setState(() {
          _currentLanguage = languageCode;
        });
      }

      // Close dialog only if context is still valid
      if (mounted && context.mounted) {
        navigator.pop();

        // Show success message
        String message = languageCode == 'vi'
            ? LanguageService.getTextSync(
                'switched_to_vietnamese',
                languageCode,
              )
            : LanguageService.getTextSync('switched_to_english', languageCode);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Optional: Reload the entire app to apply language changes immediately
      // You might want to implement a global state management for this
    } catch (e) {
      if (mounted && context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '${LanguageService.getTextSync('error', _currentLanguage)}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSignOutDialog(
    BuildContext context,
    GoogleSignInService googleSignInService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LanguageService.getTextSync('sign_out', _currentLanguage),
          ),
          content: Text(
            LanguageService.getTextSync(
              'sign_out_confirmation',
              _currentLanguage,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LanguageService.getTextSync('cancel', _currentLanguage),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop(); // Close dialog
                navigator.pop(); // Close drawer

                try {
                  await googleSignInService.signOut();

                  // Navigate to sign in page only if widget is still mounted
                  if (mounted && context.mounted) {
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => SigninPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${LanguageService.getTextSync('logout_error', _currentLanguage)}: $e',
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                LanguageService.getTextSync('sign_out', _currentLanguage),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
