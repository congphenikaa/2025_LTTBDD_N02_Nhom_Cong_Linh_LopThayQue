import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/presentation/about/bloc/about_cubit.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Không mở được link: $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("About App"), centerTitle: true),
        body: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SvgPicture.asset(AppVectors.logo, height: 100),

                  const SizedBox(height: 20),

                  Text(
                    "Music App",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Ứng dụng nghe nhạc trực tuyến.\n"
                    "Khám phá playlist và bài hát mới nhất!",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  _infoRow("Phiên bản", state.appVersion),
                  _infoRow("Nhà phát triển", state.developer),
                  _infoRow("Framework", "Flutter"),

                  const Divider(height: 40),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Liên hệ & Hỗ trợ",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _contactTile(
                    icon: Icons.email,
                    title: "Email",
                    subtitle: "your-email@gmail.com",
                    link: "mailto:your-email@gmail.com",
                  ),

                  _contactTile(
                    icon: Icons.facebook,
                    title: "Facebook",
                    subtitle: "Music App Community",
                    link: "https://facebook.com/",
                  ),

                  _contactTile(
                    icon: Icons.language,
                    title: "Website",
                    subtitle: "musicapp.com",
                    link: "https://musicapp.com",
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    "© 2025 Music App - All rights reserved.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String link,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => _openLink(link),
    );
  }
}
