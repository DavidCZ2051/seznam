import 'package:flutter/material.dart';
import '../vars.dart' as vars;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nastavení"),
        leading: IconButton(
          tooltip: "Zpět",
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            tooltip: "Smazat data",
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Smazat všechna data?"),
                  content: const Text("Tato akce je nevratná."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Zrušit"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          vars.items.clear();
                          vars.saveData();
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Smazat"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: vars.items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return AddItem(
                onAdd: () {
                  vars.saveData();
                  setState(() {});
                },
              );
            }
            return ItemWidget(vars.items[index - 1]);
          },
        ),
      ),
    );
  }
}

class AddItem extends StatefulWidget {
  const AddItem({super.key, required this.onAdd});

  final Function() onAdd;

  @override
  State<AddItem> createState() => AddItemState();
}

class AddItemState extends State<AddItem> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void addItem() {
    vars.items.add(vars.Item(
      name: _controller.text,
      count: 0,
      lastChangedDateTime: DateTime.now(),
    ));

    setState(() {
      _controller.clear();
    });

    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    formKey.currentState?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Název",
            suffixIcon: IconButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  addItem();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Název nesmí být prázdný";
            }
            return null;
          },
        ),
      ),
    );
  }
}

class ItemWidget extends StatefulWidget {
  const ItemWidget(this.item, {super.key});

  final vars.Item item;

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Others extends StatefulWidget {
  const Others({super.key});

  @override
  State<Others> createState() => _OthersState();
}

class _OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
