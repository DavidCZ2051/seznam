import 'package:flutter/material.dart';
import 'package:seznam_veci/vars.dart' as vars;
import 'package:clipboard/clipboard.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onThemeChanged});

  final Function() onThemeChanged;

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ReorderableListView(
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.list,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Položky",
                      style: TextStyle(fontSize: 26),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AddItem(
                    onAdd: () {
                      vars.saveData();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                vars.items.insert(newIndex, vars.items.removeAt(oldIndex));
                vars.saveData();
              });
            },
            footer: Others(
                onThemeChanged: widget.onThemeChanged,
                onItemsDeleted: () {
                  setState(() {});
                }),
            children: [
              for (vars.Item item in vars.items)
                ItemWidget(
                  item,
                  key: item.key,
                  onDeleted: () {
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAllItemsDialog extends StatelessWidget {
  const DeleteAllItemsDialog({super.key, required this.onConfirm});

  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Smazat všechna data?"),
      content: const Text("Tato akce je nevratná."),
      actions: <Widget>[
        TextButton(
          child: const Text("Zrušit"),
          onPressed: () => Navigator.pop(context),
        ),
        OutlinedButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.delete),
          label: const Text("Smazat"),
        ),
      ],
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
    return Form(
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
    );
  }
}

class ItemWidget extends StatefulWidget {
  const ItemWidget(this.item, {super.key, required this.onDeleted});

  final vars.Item item;
  final Function() onDeleted;

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  void deleteItem() {
    vars.items.remove(widget.item);
    vars.saveData();
    Navigator.pop(context);
    widget.onDeleted();
  }

  void showDeleteItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Smazat tuto položku?"),
          content: const Text("Tato akce je nevratná."),
          actions: <Widget>[
            TextButton(
              child: const Text("Zrušit"),
              onPressed: () => Navigator.pop(context),
            ),
            OutlinedButton.icon(
              onPressed: deleteItem,
              icon: const Icon(Icons.delete),
              label: const Text("Smazat"),
            ),
          ],
        );
      },
    );
  }

  void renameItem(String newName) {
    widget.item.name = newName;
    vars.saveData();
    setState(() {});
  }

  void showRenameItemDialog() async {
    final TextEditingController controller =
        TextEditingController(text: widget.item.name);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Přejmenovat položku"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Název nesmí být prázdný";
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Zrušit"),
              onPressed: () => Navigator.pop(context),
            ),
            OutlinedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  renameItem(controller.text);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text("Přejmenovat"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.item.name,
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: showDeleteItemDialog,
            tooltip: "Odstranit",
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            onPressed: showRenameItemDialog,
            tooltip: "Přejmenovat",
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class Others extends StatefulWidget {
  const Others({
    super.key,
    required this.onThemeChanged,
    required this.onItemsDeleted,
  });

  final Function() onThemeChanged;
  final Function() onItemsDeleted;

  @override
  State<Others> createState() => _OthersState();
}

class _OthersState extends State<Others> {
  void showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Export dat"),
          content: TextField(
            controller: TextEditingController(
              text: vars.items.toJsonString(),
            ),
            readOnly: true,
            maxLines: 10,
            style: const TextStyle(
              fontFamily: "IBM Plex Mono",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Zavřít"),
              onPressed: () => Navigator.pop(context),
            ),
            OutlinedButton(
              onPressed: () {
                FlutterClipboard.copy(vars.items.toJsonString());
                Navigator.pop(context);
              },
              child: Text("Kopírovat"),
            ),
          ],
        );
      },
    );
  }

  void showImportDataDialog() {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Import dat"),
          content: Form(
            key: formKey,
            child: TextFormField(
              maxLines: 10,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Nesmí být prázdné";
                }

                try {
                  List<vars.Item> items = [];

                  for (Map<String, dynamic> item in jsonDecode(value)) {
                    items.add(vars.Item.fromJson(item));
                  }
                  vars.items = items;
                  vars.saveData();
                  return null;
                } catch (e) {
                  return "Neplatný formát";
                }
              },
              style: const TextStyle(
                fontFamily: "IBM Plex Mono",
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Zavřít"),
              onPressed: () => Navigator.pop(context),
            ),
            OutlinedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
              child: Text("Importovat"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const Divider(),
        const Text(
          "Ostatní nastavení",
          style: TextStyle(fontSize: 26),
        ),
        ListTile(
          title: const Text("Režim aplikace"),
          leading: const Icon(Icons.brightness_4),
          trailing: DropdownButton(
            value: vars.themeMode,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text("Světlý"),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text("Tmavý"),
              ),
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text("Systémový"),
              ),
            ],
            onChanged: (value) {
              vars.themeMode = value!;
              vars.saveData();
              widget.onThemeChanged();
            },
          ),
        ),
        ListTile(
          title: const Text("Barva aplikace"),
          leading: const Icon(Icons.color_lens),
          trailing: DropdownButton(
            value: vars.color,
            items: Colors.primaries.map((color) {
              return DropdownMenuItem(
                value: color,
                child: Row(
                  children: [
                    Container(
                      color: color,
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(color.toHumanString()),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              vars.color = value!;
              vars.saveData();
              widget.onThemeChanged();
            },
          ),
        ),
        ListTile(
          title: const Text("Exportovat data"),
          leading: const Icon(Icons.upload),
          onTap: showExportDataDialog,
        ),
        ListTile(
          title: const Text("Importovat data"),
          leading: const Icon(Icons.download),
          onTap: showImportDataDialog,
        ),
        ListTile(
          title: const Text("Smazat data"),
          leading: const Icon(Icons.delete_forever),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => DeleteAllItemsDialog(
                onConfirm: () {
                  vars.items.clear();
                  vars.saveData();
                  widget.onItemsDeleted();
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
        ListTile(
          title: const Text("O aplikaci"),
          leading: const Icon(Icons.info),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "Seznam věcí",
              applicationVersion: vars.version,
              applicationLegalese: "David Vobruba",
            );
          },
        ),
      ],
    );
  }
}
