import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/methods/common_methods.dart';
import 'trip_details_page.dart';

class ScheduledTripsPage extends StatefulWidget {
  static const String id = "\webPageScheduledTrips";

  const ScheduledTripsPage({super.key});

  @override
  _ScheduledTripsPageState createState() => _ScheduledTripsPageState();
}

class _ScheduledTripsPageState extends State<ScheduledTripsPage> {
  final DatabaseReference scheduledTripsRef = FirebaseDatabase.instance.ref().child("agendamentosPendentes");
  final DatabaseReference completedTripsRef = FirebaseDatabase.instance.ref().child("agendamentosPendentes");

  CommonMethods cMethods = CommonMethods();

  void navigateToTripDetails(Map tripData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsPage(tripData: tripData),
      ),
    );
  }

  Widget buildTripRow(Map item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        cMethods.tooltipData(2, item["key"].toString(), item["key"].toString()),
        cMethods.tooltipData(1, item["userName"].toString(), item["userName"].toString()),
        cMethods.tooltipData(1, item["pickUpPlaceName"].toString(), item["pickUpPlaceName"].toString()),
        cMethods.tooltipData(1, item["destinationPlaceName"].toString(), item["destinationPlaceName"].toString()),
        cMethods.tooltipData(1, item["scheduledDateTime"].toString(), item["scheduledDateTime"].toString()),
        cMethods.tooltipData(1, item["serviceType"].toString(), item["serviceType"].toString()),
        cMethods.tooltipData(1, item["status"].toString(), item["status"].toString()),
        cMethods.data(
          1,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFF2F2F2), backgroundColor: const Color(0xFF003319), // Branco
            ),
            onPressed: () => navigateToTripDetails(item),
            child: const Text("+"),
          ),
        ),
      ],
    );
  }

  Widget buildTripsList(AsyncSnapshot snapshot, String status) {
    if (snapshot.hasError) {
      return const Center(child: Text("Erro ao carregar os dados"));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.data?.snapshot.value == null) {
      return const Center(child: Text("Nenhuma viagem encontrada."));
    }

    Map dataMap = snapshot.data.snapshot.value as Map;
    List itemsList = [];
    dataMap.forEach((key, value) {
      if (value["status"] == status) {
        itemsList.add({"key": key, ...value});
      }
    });

    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemsList.length,
      itemBuilder: (context, index) => buildTripRow(itemsList[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manipular Viagens Agendadas",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003319), // Verde Escuro
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  headerWithColor(2, "ID VIAGEM", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "USUÁRIO", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "PARTIDA", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "DESTINO", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "DATA", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "TIPO", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "STATUS", const Color(0xFF003319)), // Verde Escuro
                  headerWithColor(1, "DETALHES", const Color(0xFF003319)), // Verde Escuro
                ],
              ),
              const Divider(color: Color(0xFF003319)), // Verde Escuro
              const SizedBox(height: 18),
              const Text(
                "Viagens Agendadas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003319)), // Verde Escuro
              ),
              StreamBuilder(
                stream: scheduledTripsRef.onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return buildTripsList(snapshot, "Agendado");
                },
              ),
              const SizedBox(height: 18),
              const Text(
                "Viagens Concluídas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003319)), // Verde Escuro
              ),
              StreamBuilder(
                stream: completedTripsRef.onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return buildTripsList(snapshot, "Concluído");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerWithColor(int flex, String title, Color color) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
