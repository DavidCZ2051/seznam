import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

const String version = "2.0.0";

List<Item> items = [];
late ThemeMode themeMode;
late Color color;

class Item {
  String name;
  int count;
  DateTime lastChangedDateTime;
  Key key = Key(const Uuid().v4().toString());

  Item({
    required this.name,
    required this.count,
    required this.lastChangedDateTime,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "count": count,
        "lastChangedDateTime": lastChangedDateTime.toIso8601String(),
      };

  Item.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        count = json["count"],
        lastChangedDateTime =
            DateTime.parse(json["lastChangedDateTime"] as String);

  String get lastChangedString {
    // dd.mm.yyyy
    return "${lastChangedDateTime.day}.${lastChangedDateTime.month}.${lastChangedDateTime.year}";
  }
}

loadData() async {
  debugPrint("loading data");
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> itemsList = prefs.getStringList("items") ?? [];

  for (String item in itemsList) {
    debugPrint(item);
    items.add(Item.fromJson(jsonDecode(item)));
  }

  themeMode = const {
    "light": ThemeMode.light,
    "dark": ThemeMode.dark,
    "system": ThemeMode.system
  }[prefs.getString("theme") ?? "system"]!;

  String? colorString = prefs.getString("color");
  color = ColorExtension.fromHumanString(colorString ?? "Blue");
  debugPrint("data loaded");
}

Future saveData() async {
  debugPrint("saving data");

  List<String> itemsList = [];

  for (Item item in items) {
    String json = jsonEncode(item);
    itemsList.add(json);
    debugPrint(json);
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setStringList("items", itemsList);
  prefs.setString(
    "theme",
    const {
      ThemeMode.light: "light",
      ThemeMode.dark: "dark",
      ThemeMode.system: "system"
    }[themeMode]!,
  );
  prefs.setString("color", color.toHumanString());

  debugPrint("data saved");
}

extension ColorExtension on Color {
  static Map<Color, String> map = {
    Colors.red: "Red",
    Colors.pink: "Pink",
    Colors.purple: "Purple",
    Colors.deepPurple: "Deep Purple",
    Colors.indigo: "Indigo",
    Colors.blue: "Blue",
    Colors.lightBlue: "Light Blue",
    Colors.cyan: "Cyan",
    Colors.teal: "Teal",
    Colors.green: "Green",
    Colors.lightGreen: "Light Green",
    Colors.lime: "Lime",
    Colors.yellow: "Yellow",
    Colors.amber: "Amber",
    Colors.orange: "Orange",
    Colors.deepOrange: "Deep Orange",
    Colors.brown: "Brown",
    Colors.blueGrey: "Blue Grey",
  };

  String toHumanString() {
    return map[this]!;
  }

  static Color fromHumanString(String humanString) {
    return map.entries
        .firstWhere((element) => element.value == humanString)
        .key;
  }
}
