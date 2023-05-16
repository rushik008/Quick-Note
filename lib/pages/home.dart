import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _refreshItems(); // loading data when app starts
  }

  //  creating a reference of a box 'box_name'
  final _referenceOfBox = Hive.box('box_name');
  List<Map<String, dynamic>> _items = [];

  // creating _refreshItems function to get all the data
  void _refreshItems() {
    // this works as a loop for each item in the box
    final data = _referenceOfBox.keys.map((e) {
      // creating an object 'itemObject' for a particular key
      final itemObject = _referenceOfBox.get(e);

      // accessing the data using 'itemObject' object
      return {
        'key': e,
        'title': itemObject['title'],
        'description': itemObject['description'],
      };
    }).toList();

    // this line will inform the UI that we have new data by using setState
    setState(() {
      _items = data.reversed.toList();
      // print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    // this will add a new item into our box as a map
    await _referenceOfBox.add(newItem);

    // calling _refreshItems function to display all the data/update the UI
    _refreshItems();
  }

  // on updating already existing item
  // we call updateItem method along with that particular key and new item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _referenceOfBox.put(itemKey, item);

    _refreshItems(); // update the UI
  }

  Future<void> _deleteItem(int itemKey) async {
    await _referenceOfBox.delete(itemKey);

    _refreshItems(); // update the UI

    // Displaying snack bar after deleting the item
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An item has been deleted.'),
      ),
    );
  }

  // Dialog box to get input
  Future<void> _showMyDialog(BuildContext context, int? itemKey) async {
    // Checking whether key is null or not
    // if itemKey is not null that means key already exists
    // therefore we need to display already existing content, and then dialog box
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
    }

    // if key is null that means new item will be added
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Notes'),
          // Content of alert dialog
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Title textfield
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Description textfield
                TextFormField(
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Enter description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // action buttons of dialog box
          actions: [
            // Button to cancel the process
            TextButton(
              onPressed: () {
                // On pressing Cancel -> clear the text
                // _titleController.clear();
                // _descriptionController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            // Button to submit the response
            TextButton(
              onPressed: () {
                // if item key is null => new item will be created
                if (itemKey == null) {
                  // if no input is entered => no need to create a new item
                  if (_titleController.text != '' &&
                      _descriptionController.text != '') {
                    // passing map to _createItem function
                    _createItem({
                      'title': _titleController.text.trim(),
                      'description': _descriptionController.text.trim(),
                    });
                  }
                }
                // else if key is not null => already existing item will be updated
                if (itemKey != null) {
                  // if no input is entered => no need to create a new item => delete item
                  if (_titleController.text != '' &&
                      _descriptionController.text != '') {
                    _deleteItem(itemKey);
                  }
                  _updateItem(itemKey, {
                    // item already exists
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                  });
                }
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child:
                  (itemKey == null) ? const Text('Add') : const Text('Update'),
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
        title: const Text('Quick Notes'),
        centerTitle: true,
      ),

      // body
      body: _items.isNotEmpty
          ? ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final currentItemObject = _items[index];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3.0,
                  child: ListTile(
                    title: Text(
                      currentItemObject['title'].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      currentItemObject['description'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Edit button
                        IconButton(
                          onPressed: (() =>
                              // Now, when we want to edit any item
                              // at that time we will have a key,
                              // therefore we need to pass the key to edit that specific item
                              _showMyDialog(context, currentItemObject['key'])),
                          icon: const Icon(Icons.edit),
                        ),

                        // Delete button
                        IconButton(
                          onPressed: (() =>
                              _deleteItem(currentItemObject['key'])),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('Click this button to add notes.'),
            ),

      floatingActionButton: FloatingActionButton(
        // Initially, we are creating a new item
        // therefore while calling _showMyDialog(context, null)
        // we need to pass null as initially it will not have any key
        onPressed: () async => await _showMyDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
