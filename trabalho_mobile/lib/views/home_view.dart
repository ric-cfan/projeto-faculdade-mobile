import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:trabalho_mobile/components/entry/add_entry_dialog.dart';
import 'package:trabalho_mobile/views/entries_view.dart';

class HomeView extends StatefulWidget {
  final Box<Entry> entriesBox;
   final VoidCallback? onGoToEntries;

  const HomeView({super.key, required this.entriesBox, this.onGoToEntries});

  @override
  State<HomeView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeView> {
  int _selectedMonth = DateTime.now().month;
  final List<String> _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

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

  List<Entry> _getEntriesForCurrentMonth(List<Entry> allEntries) {
    final now = DateTime.now();
    return allEntries.where((entry) {
      return entry.date.month == _selectedMonth && entry.date.year == now.year;
    }).toList();
  }

  double _calculateBalance(List<Entry> entries) {
    double total = 0;
    for (var entry in entries) {
      total += entry.amount;
    }
    return total;
  }

  List<FlSpot> _generateChartData(List<Entry> entries) {
    // Group by day and sum the amounts
    Map<int, double> dailyTotals = {};
    
    for (var entry in entries) {
      final day = entry.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + entry.amount;
    }

    // Convert to FlSpot and sort by day
    final spots = dailyTotals.entries.map(
      (e) => FlSpot(e.key.toDouble(), e.value)
    ).toList();
    
    spots.sort((a, b) => a.x.compareTo(b.x));
    
    // Ensure we have at least two points for the chart
    if (spots.isEmpty) {
      return [
        const FlSpot(1, 0),
        const FlSpot(30, 0),
      ];
    }
    
    if (spots.length == 1) {
      return [
        spots[0],
        FlSpot(spots[0].x + 1, spots[0].y),
      ];
    }
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<Box<Entry>>(
        valueListenable: widget.entriesBox.listenable(),
        builder: (context, box, _) {
          final allEntries = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          
          final monthEntries = _getEntriesForCurrentMonth(allEntries);
          final balance = _calculateBalance(allEntries);
          final chartData = _generateChartData(monthEntries);
          
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fingest',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Balance
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Saldo Atual',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                NumberFormat.currency(
                                  locale: 'pt_BR',
                                  symbol: 'R\$',
                                ).format(balance),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Month selector
              
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...List.generate(_months.length, (index) {
                                final isSelected = _selectedMonth == index + 1;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMonth = index + 1;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _months[index],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Chart
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minX: 1,
                              maxX: 31,
                              minY: chartData.isEmpty ? 0 : chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.8,
                              maxY: chartData.isEmpty ? 1000 : chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartData,
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.5),
                                        AppColors.primary.withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        
                      ],
                    ),
                  ),
                ),
                
               
                
                // Recent entries title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Últimos Lançamentos',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onGoToEntries,
                          child: const Text(
                            'Ver tudo',
                            style: TextStyle(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Recent entries list - show only last 5
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= allEntries.length || index >= 5) return null;
                      
                      final entry = allEntries[index];
                      final all = widget.entriesBox.values.toList();
                      final idx = all.indexOf(entry);
                      
                     return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.cardPrimary,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: entry.amount >= 0
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    entry.amount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: entry.amount >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(entry.date),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.amount >= 0 ? '+' : '-'} ${NumberFormat.currency(
                                    locale: 'pt_BR',
                                    symbol: 'R\$',
                                  ).format(entry.amount.abs())}',
                                  style: TextStyle(
                                    color: entry.amount >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddEntryDialog(),
        shape: const CircleBorder(),
        tooltip: 'Novo lançamento',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}