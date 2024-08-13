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

        if (!snapshotData.hasData || !snapshotData.data!.snapshot.exists) {
          return const Center(
            child: Text("No data found"),
          );
        }

        Map<dynamic, dynamic> dataMap = snapshotData.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> itemsList = [];
        dataMap.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          itemsList.add({"key": key, ...item});
        });

        List<Map<String, dynamic>> filteredList = _applyFilters(itemsList);

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cMethods.data(
                  2,
                  Text(filteredList[index]["id"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  Text(filteredList[index]["name"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  Text(filteredList[index]["phone"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  Text(
                    filteredList[index]["car_details"] != null
                        ? filteredList[index]["car_details"]["serviceType"].toString()
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
                          .child(filteredList[index]["id"])
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
                          .child(filteredList[index]["id"])
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
                          builder: (context) => DriverDetailsPage(driverId: filteredList[index]["id"]),
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
          }),
        );
      },
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> itemsList) {
    return itemsList.where((item) {
      final searchLower = widget.searchQuery.toLowerCase();

      final idMatches = item["key"] != null && item["key"].toString().toLowerCase().contains(searchLower);
      final nameMatches = item["name"] != null && item["name"].toString().toLowerCase().contains(searchLower);
      final phoneMatches = item["phone"] != null && item["phone"].toString().toLowerCase().contains(searchLower);
      final serviceTypeMatches = item["car_details"] != null &&
          item["car_details"]["serviceType"] != null &&
          item["car_details"]["serviceType"].toString().toLowerCase().contains(searchLower);

      return idMatches || nameMatches || phoneMatches || serviceTypeMatches;
    }).toList();
  }
}
