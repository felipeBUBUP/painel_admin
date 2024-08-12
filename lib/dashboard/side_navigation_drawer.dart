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

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case DriversPage.id:
        setState(() {
          chosenScreen = DriversPage();
        });
        break;
      case UsersPage.id:
        setState(() {
          chosenScreen = UsersPage();
        });
        break;
      case TripsPage.id:
        setState(() {
          chosenScreen = TripsPage();
        });
        break;
      case ScheduledTripsPage.id:
        setState(() {
          chosenScreen = ScheduledTripsPage();
        });
        break;
    }
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
        items: const [
          AdminMenuItem(
            title: "Usuário",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Motorista",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
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
        ],
        selectedRoute: DriversPage.id,
        onSelected: (selectedPage) {
          sendAdminTo(selectedPage);
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
              SizedBox(
                width: 10,
              ),
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
              SizedBox(
                width: 10,
              ),
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
