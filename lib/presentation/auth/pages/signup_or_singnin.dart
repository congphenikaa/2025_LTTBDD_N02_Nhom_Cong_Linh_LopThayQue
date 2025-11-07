import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/presentation/auth/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignupOrSigninPage extends StatefulWidget {
  const SignupOrSigninPage({super.key});

  @override
  State<SignupOrSigninPage> createState() => _SignupOrSigninPageState();
}

class _SignupOrSigninPageState extends State<SignupOrSigninPage> {
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  void _loadLanguage() async {
    final language = await LanguageService.getCurrentLanguage();
    setState(() {
      currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BasicAppbar(),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topPattern),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.bottomPattern),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(AppImages.authBG),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppVectors.logo),
                  SizedBox(height: 55),
                  Text(
                    LanguageService.getTextSync('Enjoy Listening To Music', currentLanguage),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 21),
                  Text(
                    LanguageService.getTextSync('Music description', currentLanguage),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignupPage()
                              )
                            );
                          }, 
                          title: LanguageService.getTextSync('Register', currentLanguage)
                        ),
                       ),
                       SizedBox(width: 20,),
                       Expanded(
                        flex: 1,
                         child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (BuildContext context) => SigninPage()
                              )
                            );
                          }, 
                          child: Text(
                            LanguageService.getTextSync('Sign In', currentLanguage),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: context.isDarkMode ? Colors.white : Colors.black
                            ),
                          )
                        ),
                       )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
