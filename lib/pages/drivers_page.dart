import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/drivers_data_list.dart';

class DriversPage extends StatefulWidget {
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  CommonMethods cMethods = CommonMethods();
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Motoristas"),
        backgroundColor: const Color(0xFF003319), // Verde Escuro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: const Text(
                "Gerenciar Motoristas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003319), // Verde Escuro
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            _buildSearchField(),
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
                cMethods.header(1, "GANHOS"),
                cMethods.header(1, "STATUS"),
                cMethods.header(1, "DETALHES"),
              ],
            ),
            const Divider(color: Color(0xFF003319)), // Verde Escuro
            Expanded(
              child: DriversDataList(
                searchQuery: searchQuery,
                onMoreInfoTap: (String driverId) {
                  // Handle more info tap
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nome, modelo do carro ou telefone',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                    searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar Busca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
