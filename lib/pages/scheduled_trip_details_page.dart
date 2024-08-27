import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledTripDetailsPage extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String tripID;

  const ScheduledTripDetailsPage({super.key, required this.tripData, required this.tripID});

  @override
  _ScheduledTripDetailsPageState createState() => _ScheduledTripDetailsPageState();
}

class _ScheduledTripDetailsPageState extends State<ScheduledTripDetailsPage> {
  late Map<String, dynamic> tripData;
  final DatabaseReference tripsRef = FirebaseDatabase.instance.ref().child("agendamentosPendentes");

  @override
  void initState() {
    super.initState();
    tripData = widget.tripData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Viagem Agendada"),
        backgroundColor: const Color(0xFF0C1F0E), // Verde Escuro
        iconTheme: const IconThemeData(color: Color(0xFFF2E8D0)), // Bege para o ícone de voltar
        titleTextStyle: const TextStyle(
          color: Color(0xFFF2E8D0), // Bege para o texto do título
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection("Informações da Viagem", [
                _buildInfoTile("Nome do Usuário", tripData["userName"] ?? "N/A"),
                _buildInfoTile("Email do Usuário", tripData["userEmail"] ?? "N/A"),
                _buildInfoTile("Telefone do Usuário", tripData["userPhone"] ?? "N/A"),
                _buildInfoTile("Data e Horário da Viagem", tripData["scheduledDateTime"] ?? "N/A"),
                _buildInfoTile("Ponto de Partida", tripData["pickUpPlaceName"] ?? "N/A"),
                _buildInfoTile("Ponto de Destino", tripData["destinationPlaceName"] ?? "N/A"),
                _buildInfoTile("Tipo de Serviço", tripData["serviceType"] ?? "N/A"),
                _buildInfoTile("Status", tripData["status"] ?? "N/A"),
              ]),
              const SizedBox(height: 20),
              _buildActionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
            const Divider(color: Color(0xFF0C1F0E)), // Verde Escuro
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFF2E8D0), backgroundColor: const Color(0xFF0C1F0E), // Bege
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                _launchGoogleMap(
                  tripData["pickUpLatLng"]["latitude"],
                  tripData["pickUpLatLng"]["longitude"],
                  tripData["dropOffLatLng"]["latitude"],
                  tripData["dropOffLatLng"]["longitude"],
                  context,
                );
              },
              child: const Text("Ver no Google Maps"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: tripData["status"] == "Concluído" ? Colors.green : Colors.red, // Verde para Concluído, Vermelho para Não Concluído
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => _toggleTripStatus(context),
              child: Text(
                tripData["status"] == "Concluído" ? "Concluído" : "Marcar como Concluído",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTripStatus(BuildContext context) {
    final newStatus = tripData["status"] == "Concluído" ? "Agendado" : "Concluído";

    // Atualizando apenas o campo "status" da viagem no Firebase
    tripsRef.child(widget.tripID).update({"status": newStatus}).then((_) {
      setState(() {
        tripData["status"] = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status alterado para: $newStatus")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar o status: $error")),
      );
    });
  }

  void _launchGoogleMap(String pickUpLat, String pickUpLng, String dropOffLat, String dropOffLng, BuildContext context) async {
    final directionAPIUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunch(directionAPIUrl)) {
      await launch(directionAPIUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o Google Maps")),
      );
    }
  }
}
