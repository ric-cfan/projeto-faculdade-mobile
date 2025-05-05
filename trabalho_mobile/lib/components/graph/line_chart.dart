import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';

class LineChartSample2 extends StatefulWidget {
  final Box<Entry> entriesBox;

  const LineChartSample2({super.key, required this.entriesBox});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [AppColors.primary, AppColors.secondary];
  bool showAvg = false;

  List<FlSpot> _generateMonthlySpots() {
    final entries = widget.entriesBox.values.toList();
    final monthlyBalances = List<double>.filled(12, 0.0);

    for (final entry in entries) {
      final monthIndex = entry.date.month - 1;
      monthlyBalances[monthIndex] += entry.amount;
    }

    double runningTotal = 0.0;
    for (int i = 0; i < 12; i++) {
      runningTotal += monthlyBalances[i];
      monthlyBalances[i] = runningTotal;
    }

    return List.generate(
      12,
      (i) => FlSpot(i.toDouble(), (monthlyBalances[i] / 1000).clamp(0, double.infinity)),
    );
  }

  double _getMaxY() {
    final spots = _generateMonthlySpots();
    final highest = spots.map((e) => e.y).fold<double>(0, (prev, e) => e > prev ? e : prev);
    return highest < 6 ? 6 : (highest + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 1, top: 10),
            child: SizedBox(
              width: 50,
              height: 26,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'avg',
                  style: TextStyle(
                    fontSize: 12,
                    color: showAvg
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    String text = (value >= 0 && value < 12) ? months[value.toInt()] : '';

    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30K';
        break;
      case 5:
        text = '50K';
        break;
      default:
        return const SizedBox.shrink();
    }

    return SideTitleWidget(
      space: 6,
      meta: meta,
      child: Text(text, style: style),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final value = spot.y * 1000;
              return LineTooltipItem(
                'R\$ ${value.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: _generateMonthlySpots(),
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(12, (i) => FlSpot(i.toDouble(), 3.44)),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])!.lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])!.lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withOpacity(0.1),
                gradientColors[1].withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
