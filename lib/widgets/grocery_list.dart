import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
//import 'package:shopping_list/models/category.dart';
//import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/add_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isloading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-ceb12-default-rtdb.firebaseio.com', 'shopping-list.json');
    //final response = await http.get(url);
    
    try{
      final response = await http.get(url);
      
      if(response.statusCode >= 400){
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
    if(response.body == 'null'){ // firebase returns null as string
      setState(() {
        _isloading = false;
      });
      return;
    }
    
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final cat = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value;

      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: cat,
        ),
      );
      setState(() {
        _groceryItems = loadedItems;
        _isloading = false;
      });
    }
      
    } catch(error){
      setState(() {
        _error = 'Failed to fetch data. Check your internet connection';
      });
    }
    
    
    
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const AddItem(),
      ),
    );
    if(newItem != null){
      setState(() {
        _groceryItems.add(newItem);
        //print("New added item: ${newItem.name}");
      });
    }
    else {
      return;
    }
    //_loadItems();
     //navigating to add item screen
    // if(newItem != null){
    //   setState(() {
    //     _groceryItems.add(newItem);
    //     print("New added item: ${newItem.name}");
    //   });
    // }
    // else {
    //   return;
    // }
    final url = Uri.https(
        'flutter-prep-ceb12-default-rtdb.firebaseio.com', 'shopping-list.json');
    /*
    http.get(url).then((response) {
      print("body: ${response.body}");
      print(response.statusCode);
    });  
    */
    final response = await http.get(url);
    //print(response);
  }

  void _deleteItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'flutter-prep-ceb12-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if(response.statusCode >= 400){
      setState(() {
      _groceryItems.insert(index,item);
    });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );
    if(_isloading){
      return const Center(child: CircularProgressIndicator(),);
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
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
    // If there is error then show error message
    if(_error != null){
      return Center(
        child: Text(_error!),
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
