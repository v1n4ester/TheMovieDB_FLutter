import 'package:flutter/material.dart';
import 'package:movie_list/domain/factories/screen_factory.dart';

class MainNavigationRoutesNames {
  static const loaderWidget = '/';
  static const auth = '/auth';
  static const mainScreen = '/main_screen';
  static const movieDetails = '/main_screen/movie_details';
  static const movieTrailerWidget = '/main_screen/movie_details/trailer';
}

class MainNavigation {
  static final _screenFactory = ScreenFactory();
  String initialRoute(bool isAuth) => isAuth
      ? MainNavigationRoutesNames.mainScreen
      : MainNavigationRoutesNames.auth;

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutesNames.loaderWidget: (_) => _screenFactory.makeLoader(),
    MainNavigationRoutesNames.auth: (_) => _screenFactory.makeAuth(),
    MainNavigationRoutesNames.mainScreen: (_) => _screenFactory.makeMainScreen()
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRoutesNames.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
            builder: (context) => _screenFactory.makeMovieDetails(movieId));
      case MainNavigationRoutesNames.movieTrailerWidget:
        final arguments = settings.arguments;
        final youtubeKey = arguments is String ? arguments : '';
        return MaterialPageRoute(
            builder: (context) => _screenFactory.makeMovietrailler(youtubeKey));
      default:
        const widget = Text('Navigation error!');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }

  static void resetNavigation(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainNavigationRoutesNames.loaderWidget,
      (route) => false,
    );
  }
}
