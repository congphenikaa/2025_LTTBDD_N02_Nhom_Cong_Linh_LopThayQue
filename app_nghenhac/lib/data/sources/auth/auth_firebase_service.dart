import 'dart:convert';

import 'package:app_nghenhac/core/constants/app_urls.dart';
import 'package:app_nghenhac/data/models/auth/create_user_req.dart';
import 'package:app_nghenhac/data/models/auth/signin_user_req.dart';
import 'package:app_nghenhac/data/models/auth/user.dart';
import 'package:app_nghenhac/domain/entities/auth/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

abstract class AuthFirebaseService {

  Future<Either> signup(CreateUserReq createUserReq);
  
  Future<Either> signin(SigninUserReq signinUserReq);

  Future<Either> syncGoogleUser(CreateUserReq createUserReq);

  Future<Either> getUser();

}

class AuthFirebaseServiceImpl extends AuthFirebaseService {

  final String baseUrl = 'http://10.0.2.2:5000/api/auth';
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    try {
      // BƯỚC 1: Đăng nhập vào Firebase trước để lấy xác thực
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: signinUserReq.email,
        password: signinUserReq.password
      );

      // BƯỚC 2: Lấy Token từ Firebase
      String? token = await userCredential.user?.getIdToken();

      if (token != null) {
        // BƯỚC 3: Gửi Token lên Node.js (chung endpoint với Google Sync)
        var response = await http.post(
          Uri.parse('$baseUrl/google-sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token}),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          return Right(data); 
        } else {
          return Left(jsonDecode(response.body)['message'] ?? 'Lỗi đồng bộ Server');
        }
      } else {
        return const Left('Không lấy được Token xác thực');
      }

    } on FirebaseAuthException catch (e) {
      String message = '';
      if(e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản.';
      } else if (e.code == 'wrong-password') {
        message = 'Sai mật khẩu.';
      } else {
        message = e.message ?? 'Lỗi đăng nhập Firebase';
      }
      return Left(message);
    } catch (e) {
      return Left('Lỗi hệ thống: $e');
    }
  }
  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {
      // BƯỚC 1: Tạo tài khoản trên Firebase
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password! // Password bắt buộc
      );

      // BƯỚC 2: Lấy Token
      String? token = await userCredential.user?.getIdToken();

      if (token != null) {
        // BƯỚC 3: Gửi Token + Tên hiển thị lên Node.js
        // Node.js sẽ lưu tên này vào MongoDB
        var response = await http.post(
          Uri.parse('$baseUrl/google-sync'), // Dùng chung endpoint xác thực
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': token,
            'fullName': createUserReq.fullName 
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return const Right('Đăng ký thành công');
        } else {
          return Left(jsonDecode(response.body)['message'] ?? 'Lỗi lưu dữ liệu');
        }
      } else {
        return const Left('Không lấy được Token đăng ký');
      }

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng.';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu.';
      } else {
        message = e.message ?? 'Lỗi đăng ký Firebase';
      }
      return Left(message);
    } catch (e) {
      return Left('Lỗi hệ thống: $e');
    }
  }

  @override
  Future<Either> syncGoogleUser(CreateUserReq createUserReq) async {
    try {
      // Hàm này dùng CreateUserReq để lấy email, fullName, avatar, googleId
      var response = await http.post(
        Uri.parse('$baseUrl/google-sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(createUserReq.toJson()),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return Right(data); // Trả về thông tin User đã sync
      } else {
        return Left('Lỗi đồng bộ Google: ${response.body}');
      }
    } catch (e) {
      return Left('Lỗi kết nối Server: $e');
    }
  }
  
  @override
  Future<Either> getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user = await firebaseFirestore.collection('Users').doc(
        firebaseAuth.currentUser?.uid
      ).get();

      UserModel userModel = UserModel.fromJson(user.data()!);
      userModel.imageURl = firebaseAuth.currentUser?.photoURL ?? AppURLs.user;

      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return Left('An error occured');
    }
  }

}
