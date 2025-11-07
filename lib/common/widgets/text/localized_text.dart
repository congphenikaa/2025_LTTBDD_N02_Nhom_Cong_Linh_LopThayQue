import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:flutter/material.dart';

class LocalizedText extends StatefulWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const LocalizedText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<LocalizedText> createState() => _LocalizedTextState();
}

class _LocalizedTextState extends State<LocalizedText> {
  String _text = '';
  
  @override
  void initState() {
    super.initState();
    _loadText();
  }
  
  Future<void> _loadText() async {
    final text = await LanguageService.getText(widget.textKey);
    if (mounted) {
      setState(() {
        _text = text;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

// Helper function for quick text localization
Future<String> getLocalizedText(String key) async {
  return await LanguageService.getText(key);
}