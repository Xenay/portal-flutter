import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'views/chat_view.dart';
import 'views/main_menu_view.dart';
import 'views/models_view.dart';
import 'views/options_view.dart';
import 'views/shop_view.dart';
import 'views/user_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Chat',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenuView(),
        '/chat': (context) => ChatView(),
        '/models': (context) => ModelsView(),
        '/user': (context) => UserView(),
        '/shop': (context) => ShopView(),
        '/options': (context) => OptionsView(),
      },
    );
  }
}
