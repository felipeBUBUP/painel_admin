import 'package:admin_web_panel/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TripsDataList extends StatefulWidget {
  const TripsDataList({super.key, required String searchQuery, DateTime? selectedDate});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList> {
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();
  String searchQuery = "";
  DateTime? selectedDate;

  final TextEditingController searchController = TextEditingController();

  launchGoogleMapFromSourceToDestination(pickUpLat, pickUpLng, dropOffLat, dropOffLng) async {
    String directionAPIUrl = "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl))) {
      await launchUrl(Uri.parse(directionAPIUrl));
    } else {
      throw "Could not launch google map";
    }
  }

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

              if (!snapshotData.hasData || snapshotData.data!.snapshot.value == null) {
                return const Center(
                  child: Text(
                    "No Trips Available",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blueAccent,
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

              List<Map<String, dynamic>> filteredList = _applyFilters(itemsList);

              Map<String, List<Map<String, dynamic>>> tripsByDate = {};
              for (var item in filteredList) {
                String date = item["publishDateTime"].split(" ")[0];
                if (tripsByDate[date] == null) {
                  tripsByDate[date] = [];
                }
                tripsByDate[date]!.add(item);
              }

              return ListView.builder(
                itemCount: tripsByDate.keys.length,
                itemBuilder: (context, index) {
                  String date = tripsByDate.keys.elementAt(index);
                  List<Map<String, dynamic>> trips = tripsByDate[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          date,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...trips.map((trip) => _buildTripRow(trip)).toList(),
                    ],
                  );
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
      if (selectedDate != null &&
          !item["publishDateTime"].startsWith(DateFormat('yyyy-MM-dd').format(selectedDate!))) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !item["driverName"].toString().toLowerCase().contains(searchQuery.toLowerCase()) &&
          !item["userName"].toString().toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildTripRow(Map<String, dynamic> trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cMethods.data(2, Text(trip["tripID"].toString())),
          cMethods.data(1, Text(trip["userName"].toString())),
          cMethods.data(1, Text(trip["driverName"].toString())),
          cMethods.data(1, Text(trip["carDetails"].toString())),
          cMethods.data(1, Text(trip["publishDateTime"].toString())),
          cMethods.data(1, Text("\$ " + trip["fareAmount"].toString())),
          cMethods.data(
            1,
            ElevatedButton(
              onPressed: () {
                String pickUpLat = trip["pickUpLatLng"]["latitude"];
                String pickUpLng = trip["pickUpLatLng"]["longitude"];
                String dropOffLat = trip["dropOffLatLng"]["latitude"];
                String dropOffLng = trip["dropOffLatLng"]["longitude"];

                launchGoogleMapFromSourceToDestination(
                  pickUpLat,
                  pickUpLng,
                  dropOffLat,
                  dropOffLng,
                );
              },
              child: const Text(
                "View More",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
