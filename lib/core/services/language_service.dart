import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  // Global notifier để thông báo thay đổi ngôn ngữ
  static final ValueNotifier<String> _languageNotifier = ValueNotifier<String>('vi');
  
  // Getter để lấy notifier
  static ValueNotifier<String> get languageNotifier => _languageNotifier;
  
  // Get current language setting
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_languageKey) ?? 'vi'; // Default to Vietnamese
    
    // Đồng bộ notifier với SharedPreferences
    _languageNotifier.value = language;
    return language;
  }
  
  // Save language setting
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    // Thông báo thay đổi ngôn ngữ cho tất cả listeners
    _languageNotifier.value = languageCode;
  }
  
  // Get text based on current language
  static Future<String> getText(String key) async {
    final currentLanguage = await getCurrentLanguage();
    return _texts[key]?[currentLanguage] ?? key;
  }
  
  // Static method to get text without async (when language is known)
  static String getTextSync(String key, String language) {
    // Fallback: nếu key có gạch dưới hoặc camelCase, thử tìm key gốc
    String translatedText = _texts[key]?[language] ?? 
                           _getTextByFallback(key, language) ?? 
                           key;
    return translatedText;
  }

  // Helper method để tìm text với fallback key patterns
  static String? _getTextByFallback(String key, String language) {
    // Thử tìm với format gốc (title case)
    String titleKey = _convertToTitleCase(key);
    if (_texts[titleKey] != null) {
      return _texts[titleKey]![language];
    }
    
    // Nếu không tìm thấy, giữ nguyên key
    return null;
  }

  // Convert snake_case hoặc camelCase thành Title Case
  static String _convertToTitleCase(String input) {
    if (input.contains('_')) {
      // Convert snake_case to Title Case
      return input.split('_')
          .map((word) => word.isEmpty ? '' : 
               word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    } else if (input.contains(RegExp(r'[A-Z]'))) {
      // Convert camelCase to Title Case
      return input.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)}'
      ).trim();
    }
    
    // Nếu đã là single word, chỉ viết hoa chữ cái đầu
    return input.isEmpty ? input : 
           input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
  
  // Translation dictionary
  static const Map<String, Map<String, String>> _texts = {
    // App bar titles
    'Home': {
      'vi': 'Trang chủ',
      'en': 'Home',
    },
    'Search': {
      'vi': 'Tìm kiếm',
      'en': 'Search',
    },
    'Library': {
      'vi': 'Thư viện',
      'en': 'Library',
    },
    'Profile': {
      'vi': 'Hồ sơ',
      'en': 'Profile',
    },
    'Language Settings': {
      'vi': 'Cài đặt Ngôn ngữ',
      'en': 'Language Settings',
    },
    'News': {
      'vi': 'Tin tức',
      'en': 'News',
    },
    'Videos': {
      'vi': 'Video',
      'en': 'Videos',
    },
    'Artists': {
      'vi': 'Nghệ sĩ',
      'en': 'Artists',
    },
    'Podcasts': {
      'vi': 'Podcast',
      'en': 'Podcasts',
    },
    'now_playing': {
      'vi': 'Đang phát',
      'en': 'Now Playing',
    },
    
    // Navigation items
    'news': {
      'vi': 'Tin tức',
      'en': 'News',
    },
    'videos': {
      'vi': 'Video',
      'en': 'Videos',
    },
    'artists': {
      'vi': 'Nghệ sĩ',
      'en': 'Artists',
    },
    'podcasts': {
      'vi': 'Podcast',
      'en': 'Podcasts',
    },
    
    // Music related
    'songs': {
      'vi': 'Bài hát',
      'en': 'Songs',
    },
    'albums': {
      'vi': 'Album',
      'en': 'Albums',
    },
    'playlists': {
      'vi': 'Danh sách phát',
      'en': 'Playlists',
    },
    'playlists_featured': {
      'vi': 'Playlists Nổi Bật',
      'en': 'Featured Playlists',
    },
    'play': {
      'vi': 'Phát',
      'en': 'Play',
    },
    'pause': {
      'vi': 'Tạm dừng',
      'en': 'Pause',
    },
    'stop': {
      'vi': 'Dừng',
      'en': 'Stop',
    },
    'next': {
      'vi': 'Tiếp theo',
      'en': 'Next',
    },
    'previous': {
      'vi': 'Trước đó',
      'en': 'Previous',
    },
    'see_all': {
      'vi': 'Xem tất cả',
      'en': 'See All',
    },
    'browse_all': {
      'vi': 'Duyệt tất cả',
      'en': 'Browse all',
    },
    
    // Authentication
    'Sign In': {
      'vi': 'Đăng nhập',
      'en': 'Sign In',
    },
    'Sign Up': {
      'vi': 'Đăng ký',
      'en': 'Sign Up',
    },
    'Register': {
      'vi': 'Đăng ký',
      'en': 'Register',
    },
    'Create Account': {
      'vi': 'Tạo tài khoản',
      'en': 'Create Account',
    },
    'Login': {
      'vi': 'Đăng nhập',
      'en': 'Login',
    },
    'Logout': {
      'vi': 'Đăng xuất',
      'en': 'Logout',
    },
    'Sign Out': {
      'vi': 'Đăng xuất',
      'en': 'Sign Out',
    },
    'Continue': {
      'vi': 'Tiếp tục',
      'en': 'Continue',
    },
    'Get Started': {
      'vi': 'Bắt đầu',
      'en': 'Get Started',
    },
    
    // Form fields
    'Email': {
      'vi': 'Email',
      'en': 'Email',
    },
    'Enter Email': {
      'vi': 'Nhập Email',
      'en': 'Enter Email',
    },
    'Password': {
      'vi': 'Mật khẩu',
      'en': 'Password',
    },
    'Full Name': {
      'vi': 'Họ và tên',
      'en': 'Full Name',
    },
    
    // Common buttons and actions
    'close': {
      'vi': 'Đóng',
      'en': 'Close',
    },
    'cancel': {
      'vi': 'Hủy',
      'en': 'Cancel',
    },
    'ok': {
      'vi': 'OK',
      'en': 'OK',
    },
    'yes': {
      'vi': 'Có',
      'en': 'Yes',
    },
    'no': {
      'vi': 'Không',
      'en': 'No',
    },
    'done': {
      'vi': 'Xong',
      'en': 'Done',
    },
    'save': {
      'vi': 'Lưu',
      'en': 'Save',
    },
    'delete': {
      'vi': 'Xóa',
      'en': 'Delete',
    },
    'edit': {
      'vi': 'Sửa',
      'en': 'Edit',
    },
    'add': {
      'vi': 'Thêm',
      'en': 'Add',
    },
    'remove': {
      'vi': 'Xóa bỏ',
      'en': 'Remove',
    },
    'share': {
      'vi': 'Chia sẻ',
      'en': 'Share',
    },
    'download': {
      'vi': 'Tải xuống',
      'en': 'Download',
    },
    'favorite': {
      'vi': 'Yêu thích',
      'en': 'Favorite',
    },
    'add_to_playlist': {
      'vi': 'Thêm vào playlist',
      'en': 'Add to Playlist',
    },
    
    // App intro
    'enjoy_listening_music': {
      'vi': 'Tận hưởng việc nghe nhạc',
      'en': 'Enjoy Listening To Music',
    },
    'music_description': {
      'vi': 'Thỏa sức âm thanh của bạn, khám phá nhịp điệu riêng, và để âm nhạc đưa bạn đến những nơi mới, bởi vì mọi khoảnh khắc đều có một bản nhạc đang chờ được tìm thấy.',
      'en': 'Unleash your sound, discover your rhythm, and let the music take you to new places, because every moment has a soundtrack waiting to be found.',
    },
    'choose_mode': {
      'vi': 'Chọn giao diện',
      'en': 'Choose Mode',
    },
    'dark_mode': {
      'vi': 'Giao diện tối',
      'en': 'Dark Mode',
    },
    'light_mode': {
      'vi': 'Giao diện sáng',
      'en': 'Light Mode',
    },
    
    // Google Sign In
    'sign_in_with_google': {
      'vi': 'Đăng nhập với Google',
      'en': 'Sign in with Google',
    },
    'sign_up_with_google': {
      'vi': 'Đăng ký với Google',
      'en': 'Sign up with Google',
    },
    'signing_in': {
      'vi': 'Đang đăng nhập...',
      'en': 'Signing in...',
    },
    'or': {
      'vi': 'HOẶC',
      'en': 'OR',
    },
    
    // Drawer menu
    'account': {
      'vi': 'Tài khoản',
      'en': 'Account',
    },
    'settings': {
      'vi': 'Cài đặt',
      'en': 'Settings',
    },
    'about': {
      'vi': 'Giới thiệu',
      'en': 'About',
    },
    'help': {
      'vi': 'Trợ giúp',
      'en': 'Help',
    },
    'privacy_policy': {
      'vi': 'Chính sách bảo mật',
      'en': 'Privacy Policy',
    },
    'terms_of_service': {
      'vi': 'Điều khoản dịch vụ',
      'en': 'Terms of Service',
    },
    
    // Language settings
    'choose_language': {
      'vi': 'Chọn ngôn ngữ hiển thị',
      'en': 'Choose display language',
    },
    'change_interface_language': {
      'vi': 'Thay đổi ngôn ngữ giao diện của ứng dụng',
      'en': 'Change the interface language of the app',
    },
    'vietnamese': {
      'vi': 'Tiếng Việt',
      'en': 'Vietnamese',
    },
    'english': {
      'vi': 'Tiếng Anh',
      'en': 'English',
    },
    'switched_to_vietnamese': {
      'vi': 'Đã chuyển sang tiếng Việt',
      'en': 'Switched to Vietnamese',
    },
    'switched_to_english': {
      'vi': 'Đã chuyển sang tiếng Anh',
      'en': 'Switched to English',
    },
    
    // Music genres
    'pop': {
      'vi': 'Pop',
      'en': 'Pop',
    },
    'hip_hop': {
      'vi': 'Hip-Hop',
      'en': 'Hip-Hop',
    },
    'rock': {
      'vi': 'Rock',
      'en': 'Rock',
    },
    'jazz': {
      'vi': 'Jazz',
      'en': 'Jazz',
    },
    'classical': {
      'vi': 'Cổ điển',
      'en': 'Classical',
    },
    'electronic': {
      'vi': 'Nhạc điện tử',
      'en': 'Electronic',
    },
    
    // User account questions
    'not_a_member': {
      'vi': 'Chưa có tài khoản?',
      'en': 'Not A Member?',
    },
    'register_now': {
      'vi': 'Đăng ký ngay',
      'en': 'Register Now',
    },
    'do_you_have_account': {
      'vi': 'Bạn đã có tài khoản?',
      'en': 'Do you have an account?',
    },
    'welcome_to_music_app': {
      'vi': 'Chào mừng đến với App Nghe Nhạc',
      'en': 'Welcome to Music App',
    },
    'sign_in_to_experience': {
      'vi': 'Đăng nhập để trải nghiệm đầy đủ tính năng',
      'en': 'Sign in to experience full features',
    },
    
    // Song player
    'artist': {
      'vi': 'Nghệ sĩ',
      'en': 'Artist',
    },
    'album': {
      'vi': 'Album',
      'en': 'Album',
    },
    'duration': {
      'vi': 'Thời lượng',
      'en': 'Duration',
    },
    'repeat': {
      'vi': 'Lặp lại',
      'en': 'Repeat',
    },
    'shuffle': {
      'vi': 'Phát ngẫu nhiên',
      'en': 'Shuffle',
    },
    
    // Error messages & notifications
    'error': {
      'vi': 'Lỗi',
      'en': 'Error',
    },
    'loading': {
      'vi': 'Đang tải...',
      'en': 'Loading...',
    },
    'no_songs_found': {
      'vi': 'Không tìm thấy bài hát',
      'en': 'No songs found',
    },
    'connection_error': {
      'vi': 'Lỗi kết nối',
      'en': 'Connection error',
    },
    'try_again': {
      'vi': 'Thử lại',
      'en': 'Try again',
    },
    // Additional keys cho giao diện đẹp
    'Choose Mode': {
      'vi': 'Chọn chế độ',
      'en': 'Choose Mode',
    },
    'Dark Mode': {
      'vi': 'Chế độ tối',
      'en': 'Dark Mode',
    },
    'Light Mode': {
      'vi': 'Chế độ sáng',
      'en': 'Light Mode',
    },
    'Enjoy Listening To Music': {
      'vi': 'Tận hưởng việc nghe nhạc',
      'en': 'Enjoy Listening To Music',
    },
    'OR': {
      'vi': 'HOẶC',
      'en': 'OR',
    },
    'Signing in...': {
      'vi': 'Đang đăng nhập...',
      'en': 'Signing in...',
    },
    'Sign up with Google': {
      'vi': 'Đăng ký với Google',
      'en': 'Sign up with Google',
    },
    'Sign in with Google': {
      'vi': 'Đăng nhập với Google',
      'en': 'Sign in with Google',
    },
    'Do you have an account?': {
      'vi': 'Bạn đã có tài khoản?',
      'en': 'Do you have an account?',
    },
    'Don\'t have an account?': {
      'vi': 'Chưa có tài khoản?',
      'en': 'Don\'t have an account?',
    },
    'Login cancelled': {
      'vi': 'Đăng nhập bị hủy',
      'en': 'Login cancelled',
    },
    'Google login error': {
      'vi': 'Lỗi đăng nhập Google',
      'en': 'Google login error',
    },
    'Login successful': {
      'vi': 'Đăng nhập thành công',
      'en': 'Login successful',
    },
    'Login error': {
      'vi': 'Lỗi đăng nhập',
      'en': 'Login error',
    },
    'Signed out successfully': {
      'vi': 'Đã đăng xuất',
      'en': 'Signed out successfully',
    },
    'Sign out error': {
      'vi': 'Lỗi đăng xuất',
      'en': 'Sign out error',
    },
    'Clear All': {
      'vi': 'Xóa tất cả',
      'en': 'Clear All',
    },
    'Music description': {
      'vi': 'Giải phóng âm thanh của bạn, khám phá nhịp điệu và để âm nhạc đưa bạn đến những nơi mới, bởi vì mỗi khoảnh khắc đều có một bản nhạc đang chờ được tìm thấy.',
      'en': 'Unleash your sound, discover your rhythm, and let the music take you to new places, because every moment has a soundtrack waiting to be found.',
    },

    // Widget specific texts
    'Albums News': {
      'vi': 'Albums Mới',
      'en': 'Albums News',
    },
    'Try Again': {
      'vi': 'Thử lại',
      'en': 'Try Again',
    },
    'No Albums Found': {
      'vi': 'Không có albums nào',
      'en': 'No Albums Found',
    },
    'Cannot Load Artists List': {
      'vi': 'Không thể tải danh sách nghệ sĩ',
      'en': 'Cannot Load Artists List',
    },
    'No Artists Found': {
      'vi': 'Không có nghệ sĩ nào',
      'en': 'No Artists Found',
    },
    'Followers': {
      'vi': 'người theo dõi',
      'en': 'followers',
    },
    'Featured Playlists': {
      'vi': 'Playlists Nổi Bật',
      'en': 'Featured Playlists',
    },
    'Playlists': {
      'vi': 'Danh sách bài hát',
      'en': 'Playlists',
    },
    'No Playlists Found': {
      'vi': 'Không có playlists nào',
      'en': 'No Playlists Found',
    },
    'Cannot load playlists': {
      'vi': 'Không thể tải playlists',
      'en': 'Cannot load playlists',
    },
    'By': {
      'vi': 'Bởi',
      'en': 'By',
    },
    'See More': {
      'vi': 'Xem thêm',
      'en': 'See More',
    },
    'Error loading data': {
      'vi': 'Lỗi tải dữ liệu',
      'en': 'Error loading data',
    },
    'views': {
      'vi': 'lượt xem',
      'en': 'views',
    },
    'Opening': {
      'vi': 'Đang mở',
      'en': 'Opening',
    },

    'login_cancelled': {
      'vi': 'Đăng nhập bị hủy',
      'en': 'Login cancelled',
    },
    'google_sign_in_error': {
      'vi': 'Lỗi đăng nhập Google',
      'en': 'Google sign in error',
    },
    'sign_in_cancelled': {
      'vi': 'Đăng nhập bị hủy',
      'en': 'Sign in cancelled',
    },
    'developing_feature': {
      'vi': 'Chức năng đang phát triển',
      'en': 'Feature under development',
    },
    'settings_developing': {
      'vi': 'Chức năng cài đặt đang phát triển',
      'en': 'Settings feature under development',
    },
    'help_developing': {
      'vi': 'Chức năng trợ giúp đang phát triển',
      'en': 'Help feature under development',
    },
    'feature_will_be_updated': {
      'vi': 'Tính năng sẽ được cập nhật',
      'en': 'Feature will be updated',
    },
    'logout_error': {
      'vi': 'Lỗi đăng xuất',
      'en': 'Logout error',
    },
    
    // App info
    'app_music': {
      'vi': 'App Nghe Nhạc',
      'en': 'Music App',
    },
    'version': {
      'vi': 'Phiên bản',
      'en': 'Version',
    },
    'music_streaming_app': {
      'vi': 'Ứng dụng nghe nhạc trực tuyến với nhiều tính năng hấp dẫn.',
      'en': 'Music streaming app with many attractive features.',
    },
    'release_year': {
      'vi': 'Năm phát hành',
      'en': 'Release Year',
    },
    'track_count': {
      'vi': 'Số bài hát',
      'en': 'Track Count',
    },
    'genre': {
      'vi': 'Thể loại',
      'en': 'Genre',
    },
    'available_songs': {
      'vi': 'Số bài hát có sẵn',
      'en': 'Available songs',
    },
    
    // Common phrases
    'welcome': {
      'vi': 'Chào mừng',
      'en': 'Welcome',
    },
    'back': {
      'vi': 'Quay lại',
      'en': 'Back',
    },
    'next_step': {
      'vi': 'Bước tiếp theo',
      'en': 'Next',
    },
    'skip': {
      'vi': 'Bỏ qua',
      'en': 'Skip',
    },
    'refresh': {
      'vi': 'Làm mới',
      'en': 'Refresh',
    },
    'retry': {
      'vi': 'Thử lại',
      'en': 'Retry',
    },
    
    // About music app info
    'about_music_app': {
      'vi': 'Về ứng dụng âm nhạc',
      'en': 'About Music App',
    },
    'interface_will_update': {
      'vi': 'Giao diện sẽ được cập nhật theo ngôn ngữ đã chọn',
      'en': 'Interface will be updated according to selected language',
    },
    'menu_buttons_notifications': {
      'vi': 'Các mục menu, nút bấm và thông báo sẽ hiển thị bằng ngôn ngữ được chọn',
      'en': 'Menu items, buttons and notifications will display in chosen language',
    },
    'setting_saved_restart': {
      'vi': 'Cài đặt này sẽ được lưu và áp dụng khi khởi động lại ứng dụng',
      'en': 'This setting will be saved and applied when restarting the app',
    },
    
    // Additional keys for sign out confirmation
    'sign_out_confirmation': {
      'vi': 'Bạn có chắc chắn muốn đăng xuất?',
      'en': 'Are you sure you want to sign out?',
    },
    
    // Album related
    'all_albums': {
      'vi': 'Tất cả Albums',
      'en': 'All Albums',
    },
    'loading_albums': {
      'vi': 'Đang tải albums...',
      'en': 'Loading albums...',
    },
    'loading_album_info': {
      'vi': 'Đang tải thông tin album...',
      'en': 'Loading album info...',
    },
    'cannot_load_albums': {
      'vi': 'Không thể tải albums',
      'en': 'Cannot load albums',
    },
    'no_albums_found': {
      'vi': 'Không có albums nào',
      'en': 'No albums found',
    },
    'error_occurred': {
      'vi': 'Đã xảy ra lỗi',
      'en': 'An error occurred',
    },
    'add_to_favorite': {
      'vi': 'Thêm vào yêu thích',
      'en': 'Add to Favorite',
    },
    'share_album': {
      'vi': 'Chia sẻ album',
      'en': 'Share Album',
    },
    'album_info': {
      'vi': 'Thông tin album',
      'en': 'Album Info',
    },
    'release_date': {
      'vi': 'Ngày phát hành',
      'en': 'Release Date',
    },
    'start_playing_album': {
      'vi': 'Bắt đầu phát album',
      'en': 'Start playing album',
    },
    'shuffle_play_album': {
      'vi': 'Phát ngẫu nhiên album',
      'en': 'Shuffle play album',
    },
    'album_no_songs': {
      'vi': 'Album không có bài hát nào',
      'en': 'Album has no songs',
    },
    'removed_from_favorite': {
      'vi': 'Đã xóa khỏi yêu thích',
      'en': 'Removed from favorite',
    },
    'added_to_favorite': {
      'vi': 'Đã thêm vào yêu thích',
      'en': 'Added to favorite',
    },
    'downloading_album': {
      'vi': 'Đang tải xuống album...',
      'en': 'Downloading album...',
    },
    'feature_coming_soon': {
      'vi': 'Tính năng sẽ được cập nhật',
      'en': 'Feature coming soon',
    },
    'song_list': {
      'vi': 'Danh sách bài hát',
      'en': 'Song List',
    },
    'no_songs_in_album': {
      'vi': 'Album này hiện chưa có bài hát nào.',
      'en': 'This album currently has no songs.',
    },
    'Favorite Songs': {
      'vi': 'Bài hát yêu thích',
      'en': 'Favorite Songs',
    },
    'Cannot load albums': {
      'vi': 'Không thể tải albums',
      'en': 'Cannot load albums',
    },
    
    // About Page
    'About App': {
      'vi': 'Giới thiệu ứng dụng',
      'en': 'About App',
    },
    'Music App': {
      'vi': 'Ứng dụng âm nhạc',
      'en': 'Music App',
    },
    'App Description': {
      'vi': 'Ứng dụng âm nhạc được phát triển bởi hai sinh viên năm cuối Trường Công Nghệ Thông Tin – Đại học Phenikaa.\n\nỨng dụng mang đến trải nghiệm nghe nhạc trực tuyến tiện lợi, giao diện đẹp và dễ sử dụng.',
      'en': 'Music App developed by two final-year students from School of Information Technology – Phenikaa University.\n\nThe app provides a convenient online music listening experience with beautiful and user-friendly interface.',
    },
    'Development Team': {
      'vi': 'Đội ngũ phát triển',
      'en': 'Development Team',
    },
    'Main Developer & Logic Handler': {
      'vi': 'Chính chịu trách nhiệm phát triển app và xử lý logic',
      'en': 'Main Developer & Logic Handler',
    },
    'UI Designer & Feature Developer': {
      'vi': 'Thiết kế giao diện và hỗ trợ phát triển chức năng',
      'en': 'UI Designer & Feature Developer',
    },
    'Contact Music App': {
      'vi': 'Liên hệ Music App',
      'en': 'Contact Music App',
    },
    'Send Email': {
      'vi': 'Gửi email',
      'en': 'Send Email',
    },
    'Phenikaa University': {
      'vi': 'Đại học Phenikaa',
      'en': 'Phenikaa University',
    },
    'School of Information Technology': {
      'vi': 'Trường Công Nghệ Thông Tin',
      'en': 'School of Information Technology',
    },
    
    // Search Song Player
    'Now Playing': {
      'vi': 'Đang phát',
      'en': 'Now Playing',
    },
    'No audio URL available': {
      'vi': 'Không có URL âm thanh',
      'en': 'No audio URL available',
    },
    'Error loading song': {
      'vi': 'Lỗi tải bài hát',
      'en': 'Error loading song',
    },
    'Cannot play music': {
      'vi': 'Không thể phát nhạc',
      'en': 'Cannot play music',
    },
    
  };
}