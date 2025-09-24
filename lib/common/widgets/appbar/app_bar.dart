import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:flutter/material.dart';

class BasicAppbar extends StatelessWidget {
  const BasicAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
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
      ),
    );
  }
}