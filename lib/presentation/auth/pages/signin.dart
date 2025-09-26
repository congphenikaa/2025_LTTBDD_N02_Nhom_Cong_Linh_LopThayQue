import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/presentation/auth/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 50,
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _registerText(),
              SizedBox(height: 50,),
              _emailField(context),
              SizedBox(height: 20,),
              _passwordField(context),
              SizedBox(height: 20,),
              BasicAppButton(
                onPressed: () {}, 
                title: 'Sign In'
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerText() {
    return const Text(
      'Sign In',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter Email'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not A Member?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                 builder: (BuildContext context) => SignupPage()
                )
              );
            }, 
            child: Text(
              'Register Now',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            )
          )
        ],
      ),
    );
  }
}