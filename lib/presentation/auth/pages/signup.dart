import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signinText(context),
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
              _fullNameField(context),
              SizedBox(height: 20,),
              _emailField(context),
              SizedBox(height: 20,),
              _passwordField(context),
              SizedBox(height: 20,),
              BasicAppButton(
                onPressed: () async {
                  var result = await sl<SignupUseCase>().call(
                    params: CreateUserReq(
                      fullName: _fullName.text.toString(), 
                      email: _email.text.toString(), 
                      password: _password.text.toString()
                    )
                  );
                  result.fold(
                    (l){
                      
                    }, 
                    (r){}
                  );
                }, 
                title: 'Create Account'
              ),
            ],
          ),
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

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: const InputDecoration(
        hintText: 'Full Name'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: 'Enter Email'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      decoration: const InputDecoration(
        hintText: 'Password'
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Do you have an account?',
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
                 builder: (BuildContext context) => const SigninPage()
                )
              );
            }, 
            child: const Text(
              'Sign In',
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