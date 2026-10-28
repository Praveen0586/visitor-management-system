import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VmsApp());
}

class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Sumadhura GatePass',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
