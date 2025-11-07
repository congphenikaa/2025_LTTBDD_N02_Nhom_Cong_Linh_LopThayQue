import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:app_nghenhac/presentation/language/pages/language_settings_page.dart';
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
    try {
      final language = await LanguageService.getCurrentLanguage();
      if (mounted) {
        setState(() {
          _currentLanguage = language;
        });
      }
    } catch (e) {
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
            title: Text(LanguageService.getTextSync('Profile', _currentLanguage)),
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
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LanguageSettingsPage())
              );
              // Không cần _loadLanguage() nữa vì đã có listener
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
              LanguageService.getTextSync('Sign Out', _currentLanguage),
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


  void _showSignOutDialog(
    BuildContext context,
    GoogleSignInService googleSignInService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LanguageService.getTextSync('Sign Out', _currentLanguage)),
          content: Text(LanguageService.getTextSync('sign_out_confirmation', _currentLanguage)),
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
                LanguageService.getTextSync('Sign Out', _currentLanguage),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
