import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/button/basic_app_button.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/services/google_sign_in_service.dart';
import 'package:app_nghenhac/core/services/language_service.dart';
import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:app_nghenhac/domain/usecases/auth/syncGoogleUser.dart';
import 'package:app_nghenhac/presentation/auth/pages/signin.dart';
import 'package:app_nghenhac/presentation/home/pages/home.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GoogleSignInService _googleSignInService = sl<GoogleSignInService>();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;
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
      bottomNavigationBar: _signinText(context),
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
      ),
      body: SingleChildScrollView(
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
                      var snackbar = SnackBar(content: Text(l), behavior: SnackBarBehavior.floating,);
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }, 
                    (r){
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
                        (route) => false
                      );
                    }
                  );
                }, 
                title: LanguageService.getTextSync('Create Account', _currentLanguage)
              ),
              SizedBox(height: 20,),
              _orDivider(),
              SizedBox(height: 20,),
              _googleSignInButton(),
            ],
          ),
        ),
    );
  }

  Widget _registerText() {
    return Text(
      LanguageService.getTextSync('Register', _currentLanguage),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextField(
      controller: _fullName,
      decoration: InputDecoration(
        hintText: LanguageService.getTextSync('Full Name', _currentLanguage)
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        hintText: LanguageService.getTextSync('Enter Email', _currentLanguage)
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: LanguageService.getTextSync('Password', _currentLanguage),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ).applyDefaults(
        Theme.of(context).inputDecorationTheme
      ),
    );
  }


  Widget _orDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            LanguageService.getTextSync('OR', _currentLanguage),
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _googleSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isGoogleLoading ? null : _signInWithGoogle,
        icon: _isGoogleLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : SvgPicture.asset(
                AppVectors.google_logo,
                height: 20,
                width: 20,
              ),
        label: Text(
          _isGoogleLoading 
            ? LanguageService.getTextSync('Signing in...', _currentLanguage) 
            : LanguageService.getTextSync('Sign up with Google', _currentLanguage),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    // Hiển thị loading
    setState(() => _isGoogleLoading = true);
    
    try {
      // BƯỚC 1: Đăng nhập Google qua Service bạn đã có
      final userCredential = await _googleSignInService.signInWithGoogle();
      
      // Kiểm tra xem đăng nhập Firebase thành công chưa
      if (userCredential != null && userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        final idToken = await userCredential.user!.getIdToken();
        
        // BƯỚC 2: Chuẩn bị dữ liệu để gửi lên Node.js
        // Mapping dữ liệu từ Firebase User sang Model CreateUserReq của bạn
        CreateUserReq req = CreateUserReq(
          fullName: firebaseUser.displayName ?? "No Name",
          email: firebaseUser.email!,
          password: null, // Đăng nhập Google không có pass
          avatar: firebaseUser.photoURL,
          googleId: firebaseUser.uid ,
          token: idToken,
        );

        // BƯỚC 3: Gọi UseCase để Sync với Node.js
        // Đây chính là lúc hàm syncGoogleUser của bạn được kích hoạt
        var result = await sl<SyncGoogleUserUseCase>().call(params: req);

        // BƯỚC 4: Xử lý kết quả trả về từ Node.js
        result.fold(
          (errorMessage) {
            // Lỗi từ Server Node.js (ví dụ: server sập, lỗi mạng)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
            // Optional: Đăng xuất khỏi Firebase nếu sync lỗi để user thử lại
            _googleSignInService.signOut();
          },
          (successData) {
            // Thành công! User đã nằm an toàn trong MongoDB
            // Chuyển sang trang chủ
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
              (route) => false
            );
          }
        );

      } else {
        // User hủy chọn tài khoản Google
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập bị hủy')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      // Tắt loading
      if (mounted) setState(() => _isGoogleLoading = false);
    }
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
            LanguageService.getTextSync('do_you_have_account', _currentLanguage),
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
                 builder: (BuildContext context) => SigninPage()
                )
              );
            }, 
            child: Text(
              LanguageService.getTextSync('sign_in', _currentLanguage),
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