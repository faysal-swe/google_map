import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/app/routes/app_pages.dart';
import 'routes/app_routes.dart';

class LiveChat extends StatelessWidget {
  const LiveChat({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: Routes.googleMap,
      getPages: AppPages.routes,
    );
  }
}
