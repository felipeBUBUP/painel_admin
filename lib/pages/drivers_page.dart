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
      backgroundColor: const Color(0xFFF2F2F2), // Fundo Claro
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
                headerWithColor(2, "ID MOTORISTA", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "NOME", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "TELEFONE", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "SERVIÇO", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "STATUS", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "DETALHES", const Color(0xFF003319)), // Verde Escuro
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
          borderRadius: BorderRadius.circular(4), // Menos curvas
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por ID, CPF ou nome do motorista',
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFF2E8D0), backgroundColor: const Color(0xFF003319), // Bege
                ),
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                    searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar Busca'),
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
