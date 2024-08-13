import 'package:admin_web_panel/dashboard/dashboard.dart';
import 'package:admin_web_panel/pages/drivers_page.dart';
import 'package:admin_web_panel/pages/trips_page.dart';
import 'package:admin_web_panel/pages/users_page.dart';
import 'package:admin_web_panel/pages/scheduled_trips_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = Dashboard();

  void sendAdminTo(String route) {
    setState(() {
      switch (route) {
        case DriversPage.id:
          chosenScreen = DriversPage();
          break;
        case UsersPage.id:
          chosenScreen = UsersPage();
          break;
        case TripsPage.id:
          chosenScreen = TripsPage();
          break;
        case ScheduledTripsPage.id:
          chosenScreen = ScheduledTripsPage();
          break;
        default:
          chosenScreen = Dashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Fundo Claro
      appBar: AppBar(
        backgroundColor: const Color(0xFF4a6e3f), // Verde Escuro
        title: const Text(
          "Painel Administrativo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFF2E8D0), // Bege
          ),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: const Color(0xFF4a6e3f), // Verde Escuro
        textStyle: const TextStyle(
          color: Color(0xFFF2E8D0), // Bege
        ),
        items: [
          AdminMenuItem(
            title: "Usuário",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Viagens",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Agendamentos",
            route: ScheduledTripsPage.id,
            icon: CupertinoIcons.calendar,
          ),
          AdminMenuItem(
            title: "Motorista",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
        ],
        selectedRoute: DriversPage.id,
        onSelected: (item) {
          sendAdminTo(item.route ?? '');
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: const Color(0xFF789e6c), // Verde Suave
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Color(0xFFF2E8D0), // Bege
              ),
              SizedBox(width: 10),
              Icon(
                Icons.settings,
                color: Color(0xFFF2E8D0), // Bege
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: const Color(0xFF789e6c), // Verde Suave
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Color(0xFFF2E8D0), // Bege
              ),
              SizedBox(width: 10),
              Icon(
                Icons.computer,
                color: Color(0xFFF2E8D0), // Bege
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
