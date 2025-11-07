import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutState extends Equatable {
  final String appVersion;
  final String developer;
  final String framework;

  const AboutState({
    this.appVersion = "Loading...",
    this.developer = "Loading...",
    this.framework = "Flutter",
  });

  AboutState copyWith({
    String? appVersion,
    String? developer,
    String? framework,
  }) {
    return AboutState(
      appVersion: appVersion ?? this.appVersion,
      developer: developer ?? this.developer,
      framework: framework ?? this.framework,
    );
  }

  @override
  List<Object?> get props => [appVersion, developer, framework];
}

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(const AboutState()) {
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();

    emit(
      state.copyWith(
        appVersion: info.version,
        developer: "Linh Dev",
        framework: "Flutter",
      ),
    );
  }
}
