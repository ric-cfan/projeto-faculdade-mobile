import 'package:flutter/material.dart';

void main() => runApp(const ScaffoldExampleApp());

class ScaffoldExampleApp extends StatelessWidget {
  const ScaffoldExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ScaffoldExample());
  }
}

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  int _count = 0;
  int _selectedIndex = 0; // Para acompanhar qual item está selecionado no BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Muda o índice quando um botão for pressionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingest'),
        foregroundColor: Color.fromARGB(255, 216, 230, 242),
        backgroundColor: const Color.fromARGB(255, 13, 33, 62)
      ),
      body: Center(
        child: Text('You have pressed the button $_count times.'),
      ),
      backgroundColor: const Color.fromARGB(255, 9, 23, 42),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF88C9F2),
        onPressed: () => setState(() => _count++),
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 13, 33, 62),
        selectedItemColor: Color.fromARGB(255, 42, 122, 191),
        unselectedItemColor: Color.fromARGB(255, 216, 230, 242),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Color.fromARGB(255, 216, 230, 242)),
            label: 'Search',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color.fromARGB(255, 216, 230, 242)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Color.fromARGB(255, 216, 230, 242)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
