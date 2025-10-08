import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:flutter/material.dart';

class SongPlayerPages extends StatelessWidget {
  const SongPlayerPages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BasicAppbar(
        title: Text(
          'Now playing',
          style: TextStyle(
            fontSize: 18
          ),
        ),
      ),
    );
  }
}