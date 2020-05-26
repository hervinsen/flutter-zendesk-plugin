import 'package:flutter/material.dart';
import 'package:zendeskchat/views/chat/chat.dart';
import 'package:zendeskchat/views/dashboard/dashboard.dart';
import 'package:zendeskchat/views/splash/splash.dart';

class AppRoutes {
  Route<dynamic> onGenerateRoutes(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case SplashScreen.route:
        {
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (BuildContext context) {
              return SplashScreen();
            },
          );
        }

      case DashboardScreen.route:
        {
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (BuildContext context) {
              return DashboardScreen();
            },
          );
        }

      case ChatScreen.route:
        {
          return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            builder: (BuildContext context) {
              return ChatScreen();
            },
          );
        }

      default:
        return null;
    }
  }
}
