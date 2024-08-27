import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/methods/common_methods.dart';
import '../pages/driver_details.dart';

class DriversDataList extends StatefulWidget {
  final String searchQuery;
  final Function(String) onMoreInfoTap;

  const DriversDataList({
    required this.searchQuery,
    required this.onMoreInfoTap,
    super.key,
  });

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase = FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Ocorreu um erro. Tente novamente mais tarde.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blueAccent,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshotData.hasData || !snapshotData.data!.snapshot.exists) {
          return const Center(
            child: Text("Nenhum dado encontrado"),
          );
        }

        Map<dynamic, dynamic> dataMap = snapshotData.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> itemsList = [];

        dataMap.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          itemsList.add({"key": key, ...item});
        });

        List<Map<String, dynamic>> filteredList = _applyFilters(itemsList);

        if (filteredList.isEmpty) {
          return const Center(
            child: Text("Nenhum dado correspondente encontrado"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cMethods.data(
                  2,
                  Text(
                    filteredList[index]["cpf"]?.toString() ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                cMethods.data(
                  1,
                  Text(
                    filteredList[index]["name"]?.toString() ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                cMethods.data(
                  1,
                  Text(
                    filteredList[index]["phone"]?.toString() ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                cMethods.data(
                  1,
                  Text(
                    filteredList[index]["car_details"] != null
                        ? filteredList[index]["car_details"]["serviceType"]?.toString() ?? "No service type"
                        : "No service type",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                cMethods.data(
                  1,
                  filteredList[index]["blockStatus"] == "no"
                      ? ElevatedButton(
                    onPressed: () async {
                      await FirebaseDatabase.instance
                          .ref()
                          .child("drivers")
                          .child(filteredList[index]["key"])
                          .update(
                        {
                          "blockStatus": "yes",
                        },
                      );
                    },
                    child: const Text(
                      "Block",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      await FirebaseDatabase.instance
                          .ref()
                          .child("drivers")
                          .child(filteredList[index]["key"])
                          .update(
                        {
                          "blockStatus": "no",
                        },
                      );
                    },
                    child: const Text(
                      "Approve",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                cMethods.data(
                  1,
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverDetailsPage(driverId: filteredList[index]["key"]),
                        ),
                      );
                    },
                    child: const Text(
                      "Mais Informações",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> itemsList) {
    return itemsList.where((item) {
      final searchLower = widget.searchQuery.toLowerCase();

      final cpfMatches = item["cpf"] != null && item["cpf"].toString().toLowerCase().contains(searchLower);
      final nameMatches = item["name"] != null && item["name"].toString().toLowerCase().contains(searchLower);
      final serviceTypeMatches = item["car_details"] != null &&
          item["car_details"]["serviceType"] != null &&
          item["car_details"]["serviceType"].toString().toLowerCase().contains(searchLower);

      return cpfMatches || nameMatches || serviceTypeMatches;
    }).toList();
  }

  Future<Map<String, double>> getDriverEarningsWithLogs(String driverCpf) async {
    print("Fetching earnings for driver CPF: $driverCpf");
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(driverCpf)
        .child("earnings");

    DataSnapshot snapshot = await earningsRef.get();

    if (snapshot.exists) {
      print("Earnings data found: ${snapshot.value}");

      Map<String, dynamic> earningsData = Map<String, dynamic>.from(snapshot.value as Map);
      DateTime now = DateTime.now();
      DateTime currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      DateTime sixWeeksAgo = currentWeekStart.subtract(Duration(days: 42)); // Considerando 6 semanas anteriores

      print("Current week start: $currentWeekStart");
      print("Date six weeks ago: $sixWeeksAgo");

      Map<int, double> weeklyEarnings = {
        for (var i = 0; i < 6; i++) i: 0.0,
      };

      earningsData.forEach((key, value) {
        double? amount = value['amount'] != null ? double.tryParse(value['amount'].toString()) : null;
        DateTime? earningDate = value['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(value['timestamp'].toString()) ?? 0)
            : null;

        if (amount != null && earningDate != null) {
          print("Processing earning: $amount on date: $earningDate");

          if (earningDate.isAfter(sixWeeksAgo)) {
            int weekNumber = ((currentWeekStart.difference(earningDate).inDays) / 7).floor();

            if (weekNumber >= 0 && weekNumber < 6) {
              weeklyEarnings[weekNumber] =
                  (weeklyEarnings[weekNumber] ?? 0.0) + amount;
              print("Week $weekNumber earnings updated to: ${weeklyEarnings[weekNumber]}");
            } else {
              print("Earning ignored, out of range.");
            }
          } else {
            print("Earning ignored, too old.");
          }
        } else {
          print("Invalid earning data: amount=$amount, date=$earningDate");
        }
      });

      print("Final weekly earnings: $weeklyEarnings");

      Map<String, double> earningsDisplayData = {};
      for (var i = 0; i < 5; i++) {
        DateTime weekStart = currentWeekStart.subtract(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        String weekRange = "${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}";
        earningsDisplayData[weekRange] = weeklyEarnings[i] ?? 0.0;
      }

      print("Earnings for display: $earningsDisplayData");

      return earningsDisplayData;
    } else {
      print("No earnings data found for driver CPF: $driverCpf");
    }

    return {};
  }
}

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
                headerWithColor(2, "CPF MOTORISTA", const Color(0xFF003319)), // Verde Escuro
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
                onMoreInfoTap: (String driverCpf) {
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
                    labelText: 'Buscar por nome ou CPF',
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
