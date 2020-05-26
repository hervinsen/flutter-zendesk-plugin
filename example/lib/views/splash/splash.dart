import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zendesk_flutter_plugin_example/util/app_colors.dart';
import 'package:zendesk_flutter_plugin_example/util/debouncer.dart';
import 'package:zendesk_flutter_plugin_example/views/dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  static const route = '/';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
    );
  }

  @override
  void initState() {
    super.initState();

    Debouncer(milliseconds: 1000).run(() {
      Get.offNamed<dynamic>(DashboardScreen.route);
    });
  }
}
