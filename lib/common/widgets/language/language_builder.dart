import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:flutter/material.dart';

/// Widget helper để tự động rebuild khi ngôn ngữ thay đổi
/// Sử dụng widget này bao quanh bất kỳ widget nào cần cập nhật theo ngôn ngữ
class LanguageBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, String currentLanguage) builder;
  
  const LanguageBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<LanguageBuilder> createState() => _LanguageBuilderState();
}

class _LanguageBuilderState extends State<LanguageBuilder> {
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    
    // Lắng nghe thay đổi ngôn ngữ
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
    return widget.builder(context, _currentLanguage);
  }
}

/// Alternative: ValueListenableBuilder approach (simpler)
class SimpleLanguageBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, String currentLanguage) builder;
  
  const SimpleLanguageBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.languageNotifier,
      builder: (context, currentLanguage, child) {
        return builder(context, currentLanguage);
      },
    );
  }
}