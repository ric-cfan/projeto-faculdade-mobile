import 'package:flutter/material.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trabalho_mobile/components/entry/add_entry_dialog.dart';
import 'package:trabalho_mobile/utils/app_icons.dart';
import 'package:trabalho_mobile/database/entries_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  runApp(const ScaffoldExampleApp());
}

class ScaffoldExampleApp extends StatelessWidget {
  const ScaffoldExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaffoldExample(),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
      ),
    );
  }
}

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({Key? key}) : super(key: key);

  @override
  _ScaffoldExampleState createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  late Box<Entry> _entriesBox;

  @override
  void initState() {
    super.initState();
    _entriesBox = Hive.box<Entry>('entries');
  }

  void _showAddEntryDialog([Entry? entry, int? index]) {
    showDialog(
      context: context,
      builder: (_) => AddEntryDialog(
        entriesBox: _entriesBox,
        entryToEdit: entry,
        entryIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
      body: ValueListenableBuilder(
        valueListenable: _entriesBox.listenable(),
        builder: (context, Box<Entry> box, _) {
          final entries = box.values.toList();
          
          final Map<String, List<Entry>> grouped = {};
          for (var e in entries) {
            final date = DateFormat('dd/MM/yyyy').format(e.date);
            grouped.putIfAbsent(date, () => []).add(e);
          }
          final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              for (var date in dates) ...[
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Image.network(AppIcons.calendario, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                for (var entry in grouped[date]!)
                  Builder(builder: (ctx) {
                    final all = _entriesBox.values.toList();
                    final idx = all.indexOf(entry);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Image.network(
                              AppIcons.getUrlById(entry.iconId),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              entry.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${entry.amount >= 0 ? '+' : '-'} ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(entry.amount.abs())}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: entry.amount >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                                Text(
                                  entry.description,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          
                          Positioned(
                            top: 4,
                            right: 4,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              offset: const Offset(0, 8),
                              onSelected: (value) async {
                                if (value == 'atualizar') {
                                  _showAddEntryDialog(entry, idx);
                                } else if (value == 'excluir') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: const Text('Deseja realmente excluir este lançamento?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(c).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(c).pop(true),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await EntriesService.deleteEntry(idx);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'atualizar',
                                  height: 32,
                                  child: const Text('Atualizar'),
                                ),
                                PopupMenuItem(
                                  value: 'excluir',
                                  height: 32,
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddEntryDialog,
        shape: const CircleBorder(),
        tooltip: 'Novo lançamento',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.scaffoldBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Lançamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Gráficos'),
        ],
      ),
    );
  }
}
