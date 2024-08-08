import 'package:flutter/material.dart';
import '../widgets/trips_data_list.dart';
import '../methods/common_methods.dart';
import 'package:intl/intl.dart';

class TripsPage extends StatefulWidget {
  static const String id = "\webPageTrips";

  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  CommonMethods cMethods = CommonMethods();
  String searchQuery = "";
  DateTime? selectedDate;

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Fundo Branco
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: const Text(
                "Manage Trips",
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
            _buildSearchAndFilter(),
            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                headerWithColor(2, "ID VIAGEM", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "USUÁRIO", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "MOTORISTA", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "CARRO", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "TEMPO", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "VALOR", const Color(0xFF003319)), // Verde Escuro
                headerWithColor(1, "DETALHES", const Color(0xFF003319)), // Verde Escuro
              ],
            ),
            const Divider(color: Color(0xFF003319)), // Verde Escuro
            Expanded(
              child: TripsDataList(
                searchQuery: searchQuery,
                selectedDate: selectedDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Menos curvas
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by driver or user',
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
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFF2E8D0), backgroundColor: const Color(0xFF003319), // Bege
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        searchQuery = "";
                        selectedDate = null;
                        searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                  ),
                ],
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
