import 'package:flutter/material.dart';
//import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/add_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const AddItem(),
      ),
    ); //navigating to add item screen
    if(newItem != null){
      setState(() {
        _groceryItems.add(newItem);
       // print("New added item: ${newItem.name}");
      });
    }
    else {
      return;
    }
  }
  void _deleteItem(GroceryItem item){
    setState(() {
        _groceryItems.remove(item);
   });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction){
            _deleteItem(_groceryItems[index]);
          },
          child: ListTile(
            leading: Container(
              width: 25,
              height: 50,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            subtitle: Text(_groceryItems[index].category.name),
            trailing: Text('${_groceryItems[index].quantity}'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
}
