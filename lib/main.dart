import 'package:flutter/material.dart';
import 'package:seznam/routes/items.dart';
import 'package:seznam/routes/settings.dart';
import 'package:seznam/vars.dart' as vars;

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
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const ItemsScreen(),
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}
