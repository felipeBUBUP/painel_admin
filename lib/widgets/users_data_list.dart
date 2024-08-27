import 'package:admin_web_panel/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UsersDataList extends StatefulWidget {
  final String searchQuery;

  const UsersDataList({
    super.key,
    required this.searchQuery,
  });

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList> {
  final usersRecordsFromDatabase = FirebaseDatabase.instance.ref().child("users");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRecordsFromDatabase.onValue,
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
              "No Users Available",
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

        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return _buildUserRow(filteredList[index]);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> itemsList) {
    return itemsList.where((item) {
      final searchLower = widget.searchQuery.toLowerCase();

      final idMatches = item["key"] != null && item["key"].toString().toLowerCase().contains(searchLower);
      final nameMatches = item["name"] != null && item["name"].toString().toLowerCase().contains(searchLower);
      final emailMatches = item["email"] != null && item["email"].toString().toLowerCase().contains(searchLower);
      final phoneMatches = item["phone"] != null && item["phone"].toString().toLowerCase().contains(searchLower);
      final cpfMatches = item["cpf"] != null && item["cpf"].toString().toLowerCase().contains(searchLower);

      return idMatches || nameMatches || emailMatches || phoneMatches || cpfMatches;
    }).toList();
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cMethods.data(
            2,
            Text(
              user["id"].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          cMethods.data(
            1,
            Text(
              user["name"].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          cMethods.data(
            1,
            Text(
              user["email"].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          cMethods.data(
            1,
            Text(
              user["phone"].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          cMethods.data(
            1,
            Text(
              user["cpf"]?.toString() ?? "N/A", // Exibe o CPF ou "N/A" se não estiver disponível
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          cMethods.data(
            1,
            user["blockStatus"] == "no"
                ? ElevatedButton(
              onPressed: () async {
                await FirebaseDatabase.instance
                    .ref()
                    .child("users")
                    .child(user["id"])
                    .update({
                  "blockStatus": "yes",
                });
              },
              child: const Text(
                "Block",
                style: TextStyle(
                  color: Colors.black, // Bege
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Verde escuro
              ),
            )
                : ElevatedButton(
              onPressed: () async {
                await FirebaseDatabase.instance
                    .ref()
                    .child("users")
                    .child(user["id"])
                    .update({
                  "blockStatus": "no",
                });
              },
              child: const Text(
                "Approve",
                style: TextStyle(
                  color: Colors.black, // Bege
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF2E8D0), // Verde escuro
              ),
            ),
          ),
        ],
      ),
    );
  }
}
