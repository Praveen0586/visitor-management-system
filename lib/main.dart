import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import 'package:vms/core/configs/theme/appTheme.dart';
import 'package:vms/core/features/dashboard/view/dashboardScreen.dart';
import 'package:vms/core/features/dashboard/viewModal/dashboardviewmodal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreenPoint();
  }
}

class MainScreenPoint extends StatefulWidget {
  const MainScreenPoint({super.key});

  @override
  State<MainScreenPoint> createState() => _MainScreenPointState();
}

class _MainScreenPointState extends State<MainScreenPoint> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Visitor Management ",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark, 
      themeMode: ThemeMode.system,

      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Dashboardviewmodal()),
        ],

        child: Dashboardscreen(),
      ),
    );
  }
}
