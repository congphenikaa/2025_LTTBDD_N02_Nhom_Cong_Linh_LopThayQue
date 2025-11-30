import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_nghenhac/presentation/about/bloc/about_cubit.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/core/services/language_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    
    // Lắng nghe thay đổi ngôn ngữ từ LanguageService
    LanguageService.languageNotifier.addListener(_onLanguageChanged);
    
    // Khởi tạo ngôn ngữ hiện tại
    _currentLanguage = LanguageService.languageNotifier.value;
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

  Future<void> _launchLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Không thể mở liên kết: $uri");
    }
  }

  Widget _founderCard({
    required String name,
    required String role,
    required String facebook,
    required String email,
    required String avatarImage,
    required bool isLeft,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isLeft) ...[
            _buildAvatarSection(avatarImage, name),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoSection(name, role, facebook, email)),
          ] else ...[
            Expanded(child: _buildInfoSection(name, role, facebook, email)),
            const SizedBox(width: 16),
            _buildAvatarSection(avatarImage, name),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String avatarImage, String name) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
            ),
          ),
          child: Image.asset(
            avatarImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String name, String role, String facebook, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.isDarkMode 
            ? Colors.grey[800]?.withOpacity(0.5)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.isDarkMode 
              ? Colors.grey[700]!
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSocialButton(
                icon: Icons.email_rounded,
                onTap: () => _launchLink(
                  Uri(
                    scheme: 'mailto',
                    path: email,
                    query: 'subject=${Uri.encodeComponent(LanguageService.getTextSync('Contact Music App', _currentLanguage))}',
                  ),
                ),
                tooltip: LanguageService.getTextSync('Send Email', _currentLanguage),
              ),
              const SizedBox(width: 12),
              _buildSocialButton(
                icon: Icons.facebook_rounded,
                onTap: () => _launchLink(Uri.parse(facebook)),
                tooltip: 'Facebook',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutCubit(),
      child: Scaffold(
        backgroundColor: context.isDarkMode ? Colors.black : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            LanguageService.getTextSync('About App', _currentLanguage),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // App Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      LanguageService.getTextSync('Music App', _currentLanguage),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LanguageService.getTextSync('App Description', _currentLanguage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: context.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Team Section
              Text(
                LanguageService.getTextSync('Development Team', _currentLanguage),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 24),

              // Founder Cards
              _founderCard(
                name: "Nguyễn Hữu Công",
                role: LanguageService.getTextSync('Main Developer & Logic Handler', _currentLanguage),
                facebook: "https://www.facebook.com/huucong.cong.1",
                email: "22010399@st.phenikaa-uni.edu.vn",
                avatarImage: AppImages.cong,
                isLeft: true,
              ),

              const SizedBox(height: 24),

              _founderCard(
                name: "Lê Thị Ngọc Linh",
                role: LanguageService.getTextSync('UI Designer & Feature Developer', _currentLanguage),
                facebook: "https://www.facebook.com/ngoclinh.lethi.583671",
                email: "22010379@st.phenikaa-uni.edu.vn",
                avatarImage: AppImages.linh,
                isLeft: false,
              ),

              const SizedBox(height: 40),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.isDarkMode 
                      ? Colors.grey[800]?.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                ),
                child: Column(
                  children: [
                    Text(
                      LanguageService.getTextSync('Phenikaa University', _currentLanguage),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LanguageService.getTextSync('School of Information Technology', _currentLanguage),
                      style: TextStyle(
                        fontSize: 14,
                        color: context.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "© 2025 Music App - All rights reserved.",
                      style: TextStyle(
                        fontSize: 12,
                        color: context.isDarkMode ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
