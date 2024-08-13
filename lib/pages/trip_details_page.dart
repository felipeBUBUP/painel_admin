import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailsPage extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripDetailsPage({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Viagem"),
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
                _buildInfoTile("ID da Viagem", tripData["tripID"] ?? "N/A"),
                _buildInfoTile("Nome do Usuário", tripData["userName"] ?? "N/A"),
                _buildInfoTile("Nome do Motorista", tripData["driverName"] ?? "N/A"),
                _buildInfoTile("Carro", tripData["carDetails"] ?? "N/A"),
                _buildInfoTile("Valor da Viagem", "\$${tripData["fareAmount"]?.toStringAsFixed(2) ?? "0.00"}"),
                _buildInfoTile("Data da Publicação", tripData["publishDateTime"] ?? "N/A"),
              ]),
              const SizedBox(height: 20),
              _buildInfoSection("Pontos de Partida e Destino", [
                _buildInfoTile("Endereço de Partida", tripData["pickUpPlaceName"] ?? "N/A"),
                _buildInfoTile("Endereço de Destino", tripData["destinationPlaceName"] ?? "N/A"),
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
                );
              },
              child: const Text("Ver no Google Maps"),
            ),
          ],
        ),
      ),
    );
  }

  void _launchGoogleMap(String pickUpLat, String pickUpLng, String dropOffLat, String dropOffLng) async {
    final directionAPIUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunch(directionAPIUrl)) {
      await launch(directionAPIUrl);
    } else {
      throw "Não foi possível lançar o Google Maps";
    }
  }
}
