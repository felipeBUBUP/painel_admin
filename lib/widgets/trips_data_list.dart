import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../pages/trip_details_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TripsDataList extends StatefulWidget {
  final String searchQuery;
  final DateTime? selectedDate;

  const TripsDataList({super.key, required this.searchQuery, this.selectedDate});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList> {
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: completedTripsRecordsFromDatabase.onValue,
            builder: (BuildContext context, snapshotData) {
              if (snapshotData.hasError) {
                return const Center(
                  child: Text(
                    "Error Occurred. Try Later.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }

              if (snapshotData.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshotData.hasData || snapshotData.data!.snapshot.value == null) {
                return const Center(
                  child: Text(
                    "No Trips Available",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }

              Map<dynamic, dynamic> dataMap = snapshotData.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> itemsList = [];
              dataMap.forEach((key, value) {
                Map<String, dynamic> item = Map<String, dynamic>.from(value);
                itemsList.add({"key": key, ...item});
              });

              // Ordena as viagens por data mais recente primeiro
              itemsList.sort((a, b) {
                DateTime dateA = DateTime.tryParse(a["publishDateTime"] ?? "") ?? DateTime(1970);
                DateTime dateB = DateTime.tryParse(b["publishDateTime"] ?? "") ?? DateTime(1970);
                return dateB.compareTo(dateA);
              });

              List<Map<String, dynamic>> filteredList = _applyFilters(itemsList);

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text(
                    "Nenhuma viagem disponível.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildTripRow(filteredList[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> itemsList) {
    return itemsList.where((item) {
      bool matchesDate = widget.selectedDate == null ||
          (item["publishDateTime"] != null &&
              DateFormat('yyyy-MM-dd').format(DateTime.parse(item["publishDateTime"].split(" ")[0])) ==
                  DateFormat('yyyy-MM-dd').format(widget.selectedDate!));

      bool matchesQuery = widget.searchQuery.isEmpty ||
          (item["tripID"] != null &&
              item["tripID"].toString().toLowerCase().contains(widget.searchQuery.toLowerCase())) ||
          (item["driverName"] != null &&
              item["driverName"].toString().toLowerCase().contains(widget.searchQuery.toLowerCase())) ||
          (item["userName"] != null &&
              item["userName"].toString().toLowerCase().contains(widget.searchQuery.toLowerCase()));

      return matchesDate && matchesQuery;
    }).toList();
  }

  Widget _buildTripRow(Map<String, dynamic> trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cMethods.data(2, Text(trip["tripID"]?.toString() ?? "N/A")),
          cMethods.data(1, Text(trip["userName"]?.toString() ?? "N/A")),
          cMethods.data(1, Text(trip["driverName"]?.toString() ?? "N/A")),
          cMethods.data(1, Text(trip["carDetails"]?.toString() ?? "N/A")),
          cMethods.data(1, Text(trip["publishDateTime"]?.toString() ?? "N/A")),
          cMethods.data(1, Text("\$ " + (trip["fareAmount"]?.toString() ?? "0.00"))),
          cMethods.data(
            1,
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailsPage(tripData: trip),
                  ),
                );
              },
              child: const Text(
                "Ver Mais",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Bege
              ),
            ),
          ),
        ],
      ),
    );
  }
}
