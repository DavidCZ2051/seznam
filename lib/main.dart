import 'package:flutter/material.dart';
import 'package:seznam_veci/routes/items.dart';
import 'package:seznam_veci/routes/settings.dart';
import 'package:seznam_veci/vars.dart' as vars;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await vars.loadData();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Seznam věcí",
      themeMode: vars.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: vars.color,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: vars.color,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const ItemsScreen(),
        "/settings": (context) => SettingsScreen(
              onThemeChanged: () {
                setState(() {});
              },
            ),
      },
    );
  }
}
