import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/widgets/custom_bottom_nav.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/dashboard_screen.dart';
import 'package:vms/features/dashboard/views/scan_screen.dart';
import 'package:vms/features/dashboard/views/visitors_list_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    VisitorsListScreen(),
    ScanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: IndexedStack(
            index: vm.currentNavIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: vm.currentNavIndex,
            onTap: vm.setNavIndex,
          ),
        );
      },
    );
  }
}
