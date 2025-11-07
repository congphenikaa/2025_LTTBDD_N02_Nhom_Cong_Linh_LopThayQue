import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/presentation/choose_mode/pages/choose_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  String _currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  AppImages.introBG,
                )
              )
            ),
          ),

          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.15),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40
            ),
            child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      AppVectors.logo,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    LanguageService.getTextSync('Enjoy Listening To Music', _currentLanguage),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 21,),
                  Text(
                    LanguageService.getTextSync('Music description', _currentLanguage),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20,),
                  BasicAppButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (BuildContext context) => const ChooseModePage()
                        )
                      );
                    }, 
                    title: LanguageService.getTextSync('Get Started', _currentLanguage),
                  )
                ],
              ),
          ),
        ],
      ),
    );
  }
}