import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:flutter/material.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget{
  final Widget ? title;
  final Widget ? action;
  final Widget ? leading;
  final Color ? backgroundColor;
  final bool hideBack;
  const BasicAppbar({
    this.hideBack = false,
    this.title,
    this.action,
    this.leading,
    this.backgroundColor,
    super.key, 
    });
   

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: [
        action ?? Container()
      ],
      leading: _buildLeading(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // Nếu có leading custom, ưu tiên hiển thị leading custom
    if (leading != null) {
      return leading;
    }
    
    // Nếu hideBack = true và không có leading custom, không hiển thị gì
    if (hideBack) {
      return null;
    }
    
    // Mặc định hiển thị nút back
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      }, 
      icon: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Color.fromARGB(8, 255, 255, 255) : Color.fromARGB(8, 0, 0, 0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 15,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      )
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}