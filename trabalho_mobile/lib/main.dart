import 'package:flutter/material.dart';
import 'package:trabalho_mobile/components/app/custom_navigation_bar.dart';

import 'package:trabalho_mobile/models/entry.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trabalho_mobile/components/app/custom_app_bar.dart';

import 'package:trabalho_mobile/views/entries_view.dart';
import 'package:trabalho_mobile/views/graphs_view.dart';
import 'package:trabalho_mobile/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  runApp(const FingestApp());
}

class FingestApp extends StatefulWidget {
  const FingestApp({super.key});

  @override
  State<FingestApp> createState() => _FingestAppState();
}

class _FingestAppState extends State<FingestApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FingestScaffold(),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: const FingestScaffold(),
    theme: ThemeData(
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
    ),
  );
}

class FingestScaffold extends StatefulWidget {
  const FingestScaffold({super.key});

  @override
  State<FingestScaffold> createState() => _FingestScaffoldState();
}

class _FingestScaffoldState extends State<FingestScaffold> {
  late Box<Entry> _entriesBox;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _entriesBox = Hive.box<Entry>('entries');
  }

  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      EntriesViewStateful(entriesBox: _entriesBox),
      const HomeView(),
      const GraphsView(),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'Fingest'),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomNavigationBar(currentIndex: _currentIndex, onTap: onTap)
    );
  }
}
