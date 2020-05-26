import 'package:flutter/material.dart';
import 'package:zendesk_flutter_plugin_example/views/chat/chat.dart';
import 'package:zendesk_flutter_plugin_example/views/dashboard/dashboard.dart';
import 'package:zendesk_flutter_plugin_example/views/splash/splash.dart';

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
