import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/item_list_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar transparent and use light icons (dark background).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Items',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const ItemListPage(),
    );
  }
}