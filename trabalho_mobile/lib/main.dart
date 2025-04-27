import 'package:flutter/material.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');

  runApp(const ScaffoldExampleApp());
}

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
  late Box<Entry> _entriesBox;

  @override
  void initState() {
    super.initState();
    _entriesBox = Hive.box<Entry>('entries');
  }

  void _addEntry() {
    final entry = Entry(
      title: 'Teste',
      description: 'New Entry',
      amount: 20.0,
      date: DateTime.now(),
      iconId: 1,
    );
    _entriesBox.add(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(38, 0, 0, 0),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fingest',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _entriesBox.listenable(),
              builder: (context, Box<Entry> box, child) {
                final entries = box.values.toList();
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.title),
                      subtitle: Text('Amount: \$${entry.amount}\n${entry.description}'),
                      trailing: Text(entry.date.toString()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addEntry,
        shape: const CircleBorder(),
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(38, 0, 0, 0),
              blurRadius: 15,
              offset: Offset(0, -4),
            ),
          ],
        ),

        child: BottomNavigationBar(
          backgroundColor: AppColors.scaffoldBackground,
          selectedItemColor: AppColors.primary,
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
