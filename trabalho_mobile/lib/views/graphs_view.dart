import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trabalho_mobile/components/graph/pie_chart.dart';
import 'package:trabalho_mobile/components/graph/line_chart.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:trabalho_mobile/utils/app_icons.dart';

class GraphsView extends StatelessWidget {
  final Box<Entry> entriesBox;

  const GraphsView({super.key, required this.entriesBox});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /*Título dos Cards de Pizza*/
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Image.network(AppIcons.getUrlById("59774"), width: 24, height: 24),
                const SizedBox(width: 8),
                const Text('Distribuição de Gastos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          /*Cards de Pizza*/
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: PieChartSample2(entriesBox: entriesBox, typeId: 1),
                    ),
                  ),
                ),
                
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: PieChartSample2(entriesBox: entriesBox, typeId: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /*Título do Gráfico de Linha*/
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Image.network(AppIcons.getUrlById("59811"), width: 24, height: 24),
                const SizedBox(width: 8),
                const Text(
                  'Evolução de Receita',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          /*Gráfico de Linha*/
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              color: AppColors.cardPrimary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChartSample2(entriesBox: entriesBox),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
