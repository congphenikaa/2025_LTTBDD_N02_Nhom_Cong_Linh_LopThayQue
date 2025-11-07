import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_nghenhac/presentation/about/bloc/about_cubit.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Không thể mở liên kết: $uri");
    }
  }

  Widget _founderCard({
    required String name,
    required String role,
    required String facebook,
    required String email,
    required IconData avatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12.withOpacity(0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 26, child: Icon(avatar, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _launchLink(
                        Uri(
                          scheme: 'mailto',
                          path: email,
                          query: 'subject=Liên hệ Music App',
                        ),
                      ),
                      child: const Icon(Icons.email, size: 22),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => _launchLink(Uri.parse(facebook)),
                      child: const Icon(Icons.facebook, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Giới thiệu ứng dụng"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Spotify App được phát triển bởi hai sinh viên năm cuối "
                "Trường Công Nghệ Thông Tin – Đại học Phenikaa.\n\n"
                "Ứng dụng mang đến trải nghiệm nghe nhạc trực tuyến tiện lợi, "
                "giao diện đẹp và dễ sử dụng.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 20),

              _founderCard(
                name: "Nguyễn Hữu Công",
                role: "Chính chịu trách nhiệm phát triển app và xử lý logic",
                facebook: "https://www.facebook.com/huucong.cong.1",
                email: "22010399@st.phenikaa-uni.edu.vn",
                avatar: Icons.person,
              ),

              const SizedBox(height: 16),

              _founderCard(
                name: "Lê Thị Ngọc Linh",
                role: "Thiết kế giao diện và hỗ trợ phát triển chức năng",
                facebook: "https://www.facebook.com/ngoclinh.lethi.583671",
                email: "22010379@st.phenikaa-uni.edu.vn",
                avatar: Icons.person_outline,
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "© 2025 Music App - All rights reserved.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
