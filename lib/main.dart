import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intr_obleceni/settings.dart';
import 'dart:convert';
import 'package:intr_obleceni/vars.dart' as vars;

main() {
  runApp(
    const MaterialApp(
      home: Main(),
      debugShowCheckedModeBanner: false,
      title: "Intr - seznam oblečení",
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

loadData() async {
  print("loading  data");
  List<String> list = [];
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  list = prefs.getStringList("clothes") ?? [];
  for (String item in list) {
    vars.clothes.add(vars.Clothing.fromJson(jsonDecode(item)));
  }
  print("data loaded");
}

saveData() {
  print("saving data");
  List<String> list = [];
  for (vars.Clothing clothing in vars.clothes) {
    list.add(clothing.toJson().toString());
  }
  print("saved: $list");
  SharedPreferences.getInstance().then((prefs) {
    prefs.setStringList("clothes", list);
    print("data saved");
  });
}

class _MainState extends State<Main> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Internát - seznam oblečení"),
          actions: [
            IconButton(
              tooltip: "Nastavení",
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                ).then((_) => setState(() {}));
              },
            ),
          ],
          elevation: 2,
        ),
        body: Scrollbar(
          radius: const Radius.circular(10),
          thickness: 7,
          child: ListView(
            addAutomaticKeepAlives: true,
            children: [
              for (vars.Clothing clothing in vars.clothes)
                ClothingItem(clothing: clothing),
              const SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                for (vars.Clothing clothing in vars.clothes) {
                  clothing.count = 0;
                }
                saveData();
                setState(() {});
              },
              child: const Icon(Icons.restore),
              mini: true,
            ),
            const SizedBox(
              width: 8,
            ),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                saveData();
                setState(() {});
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.done),
            ),
          ],
        ),
      ),
    );
  }
}

class ClothingItem extends StatefulWidget {
  const ClothingItem({Key? key, required this.clothing}) : super(key: key);

  final vars.Clothing clothing;

  @override
  State<ClothingItem> createState() => _ClothingItemState();
}

class _ClothingItemState extends State<ClothingItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Text(
              "${widget.clothing.count}x ${widget.clothing.name}",
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: "Resetovat počet",
            onPressed: () {
              widget.clothing.count = 0;
              setState(() {});
              saveData();
            },
            icon: const Icon(Icons.restore),
          ),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                style: const TextStyle(fontSize: 20),
                onChanged: (value) {
                  try {
                    widget.clothing.count = int.parse(value);
                  } catch (e) {
                    return;
                  }
                },
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
