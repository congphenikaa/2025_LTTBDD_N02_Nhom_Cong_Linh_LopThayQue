import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'vi'; // Default to Vietnamese
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    
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
        _selectedLanguage = LanguageService.languageNotifier.value;
      });
    }
  }

  Future<void> _loadSelectedLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    if (mounted) {
      setState(() {
        _selectedLanguage = language;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    await LanguageService.saveLanguage(languageCode);
    // Không cần setState vì listener sẽ tự động cập nhật
    
    // Show confirmation
    _showSnackBar(
      languageCode == 'vi' 
        ? 'Đã chuyển sang tiếng Việt' 
        : 'Switched to English'
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      appBar: BasicAppbar(
        title: Text(
          _selectedLanguage == 'vi' ? 'Cài đặt Ngôn ngữ' : 'Language Settings',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 600 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      _buildHeader(isDesktop: isDesktop, isTablet: isTablet),
                      const SizedBox(height: 30),
                      
                      // Language options
                      _buildLanguageOption(
                        languageCode: 'vi',
                        languageName: 'Tiếng Việt',
                        flagEmoji: '🇻🇳',
                        subtitle: 'Vietnamese',
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLanguageOption(
                        languageCode: 'en',
                        languageName: 'English',
                        flagEmoji: '🇺🇸',
                        subtitle: 'Tiếng Anh',
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Music app related info
                      _buildMusicAppInfo(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader({bool isDesktop = false, bool isTablet = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.language,
            size: isDesktop ? 60 : (isTablet ? 50 : 40),
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedLanguage == 'vi' 
              ? 'Chọn ngôn ngữ hiển thị' 
              : 'Choose display language',
            style: TextStyle(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedLanguage == 'vi'
              ? 'Thay đổi ngôn ngữ giao diện của ứng dụng'
              : 'Change the interface language of the app',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String languageCode,
    required String languageName,
    required String flagEmoji,
    required String subtitle,
    bool isDesktop = false,
    bool isTablet = false,
  }) {
    final isSelected = _selectedLanguage == languageCode;
    
    return GestureDetector(
      onTap: () => _saveLanguagePreference(languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (context.isDarkMode ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (context.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Flag emoji
            Container(
              width: isDesktop ? 60 : (isTablet ? 50 : 40),
              height: isDesktop ? 60 : (isTablet ? 50 : 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.isDarkMode 
                  ? Colors.grey[700] 
                  : Colors.grey[100],
              ),
              child: Center(
                child: Text(
                  flagEmoji,
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                        ? AppColors.primary
                        : (context.isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: context.isDarkMode 
                        ? Colors.white60 
                        : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode 
          ? Colors.grey[800]?.withOpacity(0.5)
          : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedLanguage == 'vi' 
                  ? 'Về ứng dụng âm nhạc' 
                  : 'About Music App',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedLanguage == 'vi'
              ? '• Giao diện sẽ được cập nhật theo ngôn ngữ đã chọn\n• Các mục menu, nút bấm và thông báo sẽ hiển thị bằng ngôn ngữ được chọn\n• Cài đặt này sẽ được lưu và áp dụng khi khởi động lại ứng dụng'
              : '• Interface will be updated according to selected language\n• Menu items, buttons and notifications will display in chosen language\n• This setting will be saved and applied when restarting the app',
            style: TextStyle(
              fontSize: 12,
              color: context.isDarkMode 
                ? Colors.white70 
                : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}