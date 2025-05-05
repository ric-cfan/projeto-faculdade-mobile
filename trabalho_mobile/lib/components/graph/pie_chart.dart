import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/components/graph/indicator.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:trabalho_mobile/utils/app_icons.dart';

class PieChartSample2 extends StatefulWidget {
  final Box<Entry>? entriesBox;
  final int typeId;

  const PieChartSample2({
    super.key,
    required this.entriesBox,
    required this.typeId,
  });

  @override
  State<PieChartSample2> createState() => _PieChartSample2State();
}

class _PieChartSample2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse?.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse!
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 15,
                sections: _buildChartSections(widget.typeId),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: _buildIndicators(widget.typeId),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections(int typeId) {
    final box = widget.entriesBox;

    if (box == null || box.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey[300],
          value: 1,
          title: '',
        ),
      ];
    }

    final entries = box.values.toList();

    double primary = 0;
    double secondary = 0;

    if (typeId == 1) {
      primary = entries
          .where((e) => e.amount >= 0)
          .fold(0.0, (sum, e) => sum + e.amount);
      secondary = entries
          .where((e) => e.amount < 0)
          .fold(0.0, (sum, e) => sum + e.amount.abs());
    } else if (typeId == 2) {
      secondary = entries
          .where((e) =>
              e.amount < 0 && e.iconId == AppIcons.investimentoId)
          .fold(0.0, (sum, e) => sum + e.amount.abs());
      primary = entries
          .where((e) =>
              e.amount < 0 && e.iconId != AppIcons.investimentoId)
          .fold(0.0, (sum, e) => sum + e.amount.abs());
    }

    final total = primary + secondary;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[300],
          value: 1,
          title: '',
        ),
      ];
    }

    final primaryPercent = (primary / total) * 100;
    final secondaryPercent = (secondary / total) * 100;

    const labelStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    final colors = typeId == 1
        ? [AppColors.secondary, AppColors.textPrimary]
        : [AppColors.textPrimary, AppColors.primary];

    return [
      PieChartSectionData(
        color: colors[0],
        value: primary,
        title: '${primaryPercent.toStringAsFixed(0)}%',
        radius: 45,
        titleStyle: labelStyle,
      ),
      PieChartSectionData(
        color: colors[1],
        value: secondary,
        title: '${secondaryPercent.toStringAsFixed(0)}%',
        radius: 45,
        titleStyle: labelStyle,
      ),
    ];
  }

  List<Widget> _buildIndicators(int typeId) {
    if (typeId == 1) {
      return const [
        Indicator(color: AppColors.secondary, text: 'Entrada', isSquare: false),
        Indicator(color: AppColors.textPrimary, text: 'Saída', isSquare: false),
      ];
    } else {
      return const [
        Indicator(color: AppColors.primary, text: 'Investimento', isSquare: false),
        Indicator(color: AppColors.textPrimary, text: 'Saída', isSquare: false),
      ];
    }
  }
}
