import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seznam/vars.dart' as vars;

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  void resetItemsCountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Resetovat počet položek?"),
          content: const Text("Opravdu chcete resetovat počet všech položek?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Zrušit"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            OutlinedButton(
              child: const Text("Resetovat"),
              onPressed: () {
                setState(() {
                  for (vars.Item item in vars.items) {
                    item.count = 0;
                    item.lastChangedDateTime = DateTime.now();
                  }
                  vars.saveData();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seznam věcí"),
        actions: <Widget>[
          IconButton(
            tooltip: "Nastavení",
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: (vars.items.isNotEmpty)
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (vars.Item item in vars.items) ItemWidget(item: item),
                  ],
                ),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Zatím žádná položka",
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Přejděte do nastavení",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: (vars.items.isNotEmpty)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  tooltip: "Resetovat počet",
                  heroTag: "btn1",
                  mini: true,
                  onPressed: resetItemsCountDialog,
                  child: const Icon(Icons.restore),
                ),
                const SizedBox(
                  width: 8,
                ),
                FloatingActionButton(
                  tooltip: "Uložit",
                  heroTag: "btn2",
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Icon(Icons.save),
                ),
              ],
            )
          : null,
    );
  }
}

class ItemWidget extends StatefulWidget {
  const ItemWidget({Key? key, required this.item}) : super(key: key);

  final vars.Item item;

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "${widget.item.count}x ",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: widget.item.name,
                        style: TextStyle(
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.white
                                  : Colors.black,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child:
                      Text("Poslední změna: ${widget.item.lastChangedString}"),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Resetovat počet",
            onPressed: () {
              widget.item.count = 0;
              widget.item.lastChangedDateTime = DateTime.now();
              vars.saveData();
              setState(() {});
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
                    widget.item.count = int.parse(value);
                    widget.item.lastChangedDateTime = DateTime.now();
                  } catch (e) {
                    return;
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
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
