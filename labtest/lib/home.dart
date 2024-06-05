import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _counter = 0;

  final List<Widget> _children = [ListViewPage(0), CounterPage(0)];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _children[0] = ListViewPage(_counter);
      _children[1] = CounterPage(_counter);
    });
  }

  void updateCounter(int counter) {
    setState(() {
      _counter = counter;
      _children[0] = ListViewPage(_counter);
      _children[1] = CounterPage(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.countertops),
            label: 'Counter',
          )
        ],
      ),
    );
  }
}

class ListViewPage extends StatefulWidget {
  final int itemCount;
  ListViewPage(this.itemCount);

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _items = data.take(widget.itemCount).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List View')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          // Determine the background color based on the index
          Color backgroundColor =
              index % 2 == 0 ? Colors.orange : Colors.lightBlue;

          return Container(
            color: backgroundColor,
            child: ListTile(
              title: Text(
                _items[index]['title'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _items[index]['body'],
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  final int initialCounter;
  CounterPage(this.initialCounter);

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter;

  _CounterPageState() : _counter = 0;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialCounter;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    // Access the parent state to update the counter value
    (context.findAncestorStateOfType<_HomePageState>())
        ?.updateCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: Text('Counter: $_counter', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.add),
      ),
    );
  }
}
