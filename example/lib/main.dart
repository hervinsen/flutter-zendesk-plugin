import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zendesk_flutter_plugin_example/routes.dart';
import 'package:zendesk_flutter_plugin_example/util/app_colors.dart';
import 'package:zendesk_flutter_plugin_example/views/splash/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zendesk Demo',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: AppRoutes().onGenerateRoutes,
      initialRoute: SplashScreen.route,
    );
  }
}
