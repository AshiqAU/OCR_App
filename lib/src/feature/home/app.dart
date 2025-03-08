import 'package:flutter/material.dart';
import '../view/home_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}


class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      routes: {
        HomePage.routeName: (context) =>  HomePage()
      },
    );
  }
}
