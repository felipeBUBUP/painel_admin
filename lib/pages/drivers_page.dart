import 'package:admin_web_panel/methods/common_methods.dart';
import 'package:admin_web_panel/widgets/drivers_data_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DriversPage extends StatefulWidget {
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  CommonMethods cMethods = CommonMethods();

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
                  "Manage Drivers",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  cMethods.header(2, "ID MOTORISTA"),
                  cMethods.header(1, "FOTO"),
                  cMethods.header(1, "NOME"),
                  cMethods.header(1, "CARRO"),
                  cMethods.header(1, "TELEFONE"),
                  cMethods.header(1, "RECEBIDO"),
                  cMethods.header(1, "AÇÃO"),
                  cMethods.header(1, "MAIS INFORMAÇÕES"), // Nova coluna
                ],
              ),
              // display data
              DriversDataList(onMoreInfoTap: showDriverDetails), // Passe a função de callback
            ],
          ),
        ),
      ),
    );
  }

  void showDriverDetails(String driverId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DriverDetails(driverId: driverId);
      },
    );
  }
}

class DriverDetails extends StatelessWidget {
  final String driverId;

  const DriverDetails({required this.driverId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(driverId);

    return FutureBuilder(
      future: driverRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No data found"));
        }

        Map driverData = snapshot.data!.value as Map;
        Map<String, String> documentUrls = {
          'Negativa Antecedentes Federal': driverData['documents']['negativa_antecedentes_federal'] ?? '',
          'Negativa Antecedentes Estadual': driverData['documents']['negativa_antecedentes_estadual'] ?? '',
          'Negativa Antecedentes Militar': driverData['documents']['negativa_antecedentes_militar'] ?? '',
          'CNH': driverData['documents']['cnh'] ?? '',
          'RG': driverData['documents']['rg'] ?? '',
          'Toxicológico': driverData['documents']['toxicologico'] ?? '',
          'Foto da Frente': driverData['car_details']['images']['frente'] ?? '',
          'Foto da Traseira': driverData['car_details']['images']['traseira'] ?? '',
          'Foto Lateral Direita': driverData['car_details']['images']['lateral_direita'] ?? '',
          'Foto Lateral Esquerda': driverData['car_details']['images']['lateral_esquerda'] ?? '',
          'Foto do Chassi': driverData['car_details']['images']['chassi'] ?? '',
          'Foto dos Pneus': driverData['car_details']['images']['pneus'] ?? '',
        };



        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalhes do Motorista', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...documentUrls.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: entry.value.isNotEmpty
                          ? () async {
                        await downloadFile(context, entry.value, entry.key);
                      }
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> downloadFile(BuildContext context, String url, String fileName) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var documentDirectory = await getApplicationDocumentsDirectory();
        File file = File('${documentDirectory.path}/$fileName');

        file.writeAsBytesSync(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Arquivo $fileName baixado com sucesso!")));
      } else {
        throw Exception('Failed to load file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao baixar o arquivo $fileName")));
    }
  }
}
