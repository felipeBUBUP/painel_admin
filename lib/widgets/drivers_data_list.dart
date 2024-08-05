import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/methods/common_methods.dart';

class DriversDataList extends StatefulWidget {
  final Function(String) onMoreInfoTap;

  const DriversDataList({required this.onMoreInfoTap, super.key});

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

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemsList.length,
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cMethods.data(
                  2,
                  Text(itemsList[index]["id"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  itemsList[index]["photo"] != null
                      ? Image.network(
                    itemsList[index]["photo"].toString(),
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  )
                      : const Text("No photo"),
                ),
                cMethods.data(
                  1,
                  Text(itemsList[index]["name"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  Text(
                      itemsList[index]["car_details"]["carModel"].toString() +
                          " - " +
                          itemsList[index]["car_details"]["carNumber"]
                              .toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  Text(itemsList[index]["phone"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                cMethods.data(
                  1,
                  itemsList[index]["earnings"] != null
                      ? Text("\$ " + itemsList[index]["earnings"].toString())
                      : const Text("\$ 0"),
                ),
                cMethods.data(
                  1,
                  itemsList[index]["blockStatus"] == "no"
                      ? ElevatedButton(
                    onPressed: () async {
                      await FirebaseDatabase.instance
                          .ref()
                          .child("drivers")
                          .child(itemsList[index]["id"])
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
                          .child(itemsList[index]["id"])
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
                      widget.onMoreInfoTap(itemsList[index]["id"]);
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
}
