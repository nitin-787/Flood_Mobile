import 'package:flood_mobile/Pages/home_screen.dart';
import 'package:flood_mobile/Pages/login_screen.dart';
import 'package:flood_mobile/Pages/splash_screen.dart';
import 'package:flood_mobile/Pages/torrent_content_screen.dart';
import 'package:flood_mobile/Pages/video_stream_screen.dart';
import 'package:flood_mobile/Provider/torrent_content_provider.dart';
import 'package:flood_mobile/Route/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Arguments/torrent_content_page_arguments.dart';
import 'Arguments/video_stream_screen_arguments.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.splashScreenRoute:
        final args = settings.arguments as int?;
        return MaterialPageRoute(
            builder: (context) => SplashScreen(themeIndex: args));
      case Routes.loginScreenRoute:
        final args = settings.arguments as int?;
        return MaterialPageRoute(
            builder: (context) => LoginScreen(themeIndex: args));
      case Routes.homeScreenRoute:
        final args = settings.arguments as int?;
        return MaterialPageRoute(
            builder: (context) => HomeScreen(themeIndex: args));
      case Routes.torrentContentScreenRoute:
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<TorrentContentProvider>(
                create: (context) => TorrentContentProvider(),
              ),
            ],
            child: TorrentContentScreen(
              arguments: args as TorrentContentPageArguments,
            ),
          ),
        );
      case Routes.streamVideoScreenRoute:
        return MaterialPageRoute(
            builder: (context) => VideoStreamScreen(
                  args: args as VideoStreamScreenArguments,
                ));
      default:
        final args = settings.arguments as int?;
        return MaterialPageRoute(
            builder: (context) => LoginScreen(themeIndex: args));
    }
  }
}
