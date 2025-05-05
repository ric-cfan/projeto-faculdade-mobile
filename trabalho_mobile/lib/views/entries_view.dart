import 'package:flutter/material.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:trabalho_mobile/utils/app_icons.dart';
import 'package:trabalho_mobile/database/entries_service.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trabalho_mobile/components/entry/add_entry_dialog.dart';

class EntriesViewStateful extends StatefulWidget {
  final Box<Entry> entriesBox;

  const EntriesViewStateful({super.key, required this.entriesBox});

  @override
  State<EntriesViewStateful> createState() => _EntriesViewStatefulState();
}

class _EntriesViewStatefulState extends State<EntriesViewStateful> {
  void _showAddEntryDialog([Entry? entry, int? index]) {
    showDialog(
      context: context,
      builder: (_) => AddEntryDialog(
        entriesBox: widget.entriesBox,
        entryToEdit: entry,
        entryIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<Box<Entry>>(
        valueListenable: widget.entriesBox.listenable(),
        builder: (context, box, _) {
          final entries = box.values.toList()
              ..sort((a, b) => b.date.compareTo(a.date));
          final Map<String, List<Entry>> groupedEntries = {};

          for (var e in entries) {
            final date = DateFormat('dd/MM/yyyy').format(e.date);
            groupedEntries.putIfAbsent(date, () => []).add(e);
          }
          
          final dates = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                for (var entry in groupedEntries[date]!)
                  Builder(builder: (ctx) {
                    final all = widget.entriesBox.values.toList();
                    final idx = all.indexOf(entry);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${entry.amount >= 0 ? '+' : '-'} '
                                    '${NumberFormat.simpleCurrency(locale: 'pt_BR').format(entry.amount.abs())}',
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
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'atualizar', height: 32, child: Text('Atualizar')),
                                const PopupMenuItem(value: 'excluir', height: 32, child: Text('Excluir')),
                              ],
                              onSelected: (value) async {
                                if (value == 'atualizar') {
                                  _showAddEntryDialog(entry, idx);
                                } else {
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
        onPressed: () => _showAddEntryDialog(),
        shape: const CircleBorder(),
        tooltip: 'Novo lançamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
