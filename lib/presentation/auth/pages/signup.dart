import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _registerText(),
            _fullNameField(),
          ],
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Register',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  Widget _fullNameField() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.all(30),
        border: OutlineInputBorder(

        )
      ),
    );
  }
}