import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDetailsPage extends StatefulWidget {
  final String driverId;

  const DriverDetailsPage({required this.driverId, super.key});

  @override
  _DriverDetailsPageState createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  late DatabaseReference driverRef;
  double currentWeekEarnings = 0.0;
  List<double> lastFiveWeeksEarnings = List.filled(5, 0.0);
  List<FlSpot> lineChartData = [];
  List<String> weekDates = [];
  List<Map<String, dynamic>> recentTrips = [];

  @override
  void initState() {
    super.initState();
    driverRef = FirebaseDatabase.instance.ref().child("drivers").child(widget.driverId);
    getTotalEarningsOfDriver();
    getRecentTrips();
  }

  getRecentTrips() async {
    DatabaseReference tripsRef = FirebaseDatabase.instance.ref().child("tripRequests");

    tripsRef.orderByChild("date").limitToLast(5).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map tripsMap = event.snapshot.value as Map;
        List<Map<String, dynamic>> tripsList = [];
        tripsMap.forEach((key, value) {
          if (value["status"] == "ended" && value["driverID"] == widget.driverId) {
            Map<String, dynamic> trip = Map<String, dynamic>.from(value);
            trip['key'] = key;
            tripsList.add(trip);
          }
        });

        setState(() {
          recentTrips = tripsList.reversed.toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxYValue = lineChartData.isNotEmpty
        ? (lineChartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b).ceilToDouble() + 10).ceilToDouble()
        : 10;

    maxYValue = maxYValue % 10 == 0 ? maxYValue : (maxYValue + (10 - maxYValue % 10)).ceilToDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Motorista"),
        backgroundColor: const Color(0xFF0C1F0E), // Verde Escuro
        iconTheme: const IconThemeData(color: Color(0xFFF2E8D0)), // Bege para o ícone de voltar
        titleTextStyle: const TextStyle(
          color: Color(0xFFF2E8D0), // Bege para o texto do título
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<DataSnapshot>(
        future: driverRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar os dados."));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Nenhum dado encontrado."));
          }

          Map<dynamic, dynamic> driverData = snapshot.data!.value as Map<dynamic, dynamic>? ?? {};

          return Container(
            color: const Color(0xFFF2F2F2), // Branco
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection("Informações Pessoais", [
                    _buildInfoTile("Nome", driverData["name"] ?? "N/A"),
                    _buildInfoTile("Email", driverData["email"] ?? "N/A"),
                    _buildInfoTile("Telefone", driverData["phone"] ?? "N/A"),
                    if (driverData["photo"] != null)
                      _buildPhotoDownloadTile("Foto do Motorista", driverData["photo"]),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection("Detalhes do Carro", [
                    _buildInfoTile("Modelo do Carro", driverData["car_details"]?["carModel"] ?? "N/A"),
                    _buildInfoTile("Número do Carro", driverData["car_details"]?["carNumber"] ?? "N/A"),
                    _buildInfoTile("Cor do Carro", driverData["car_details"]?["carColor"] ?? "N/A"),
                    _buildInfoTile("Ano do Carro", driverData["car_details"]?["carYear"]?.toString() ?? "N/A"),
                    _buildInfoTile("Tipo de Serviço", driverData["car_details"]?["serviceType"] ?? "N/A"),
                  ]),
                  const SizedBox(height: 20),
                  _buildEarningsDashboard(),
                  const SizedBox(height: 20),
                  _buildRecentTrips(),
                  const SizedBox(height: 20),
                  _buildInfoSection("Fotos", _buildPhotoWidgets(driverData['car_details'])),
                  const SizedBox(height: 20),
                  _buildInfoSection("Documentos", _buildDocumentWidgets(driverData)),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFF2F2F2), backgroundColor: const Color(0xFF0C1F0E), // Branco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // Menos curvas
                        ),
                      ),
                      onPressed: () async {
                        String newStatus = driverData["blockStatus"] == "no" ? "yes" : "no";
                        await driverRef.update({"blockStatus": newStatus});
                        setState(() {});
                      },
                      child: Text(driverData["blockStatus"] == "no" ? "Bloquear" : "Aprovar"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
            const Divider(color: Color(0xFF0C1F0E)), // Verde Escuro
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDownloadTile(String title, String photoUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1F0E), // Verde Escuro
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: IconButton(
              icon: const Icon(Icons.download),
              color: const Color(0xFF0C1F0E), // Verde Escuro
              onPressed: () {
                _launchURL(photoUrl);
              },
            ),
          ),
        ],
      ),
    );
  }

  getTotalEarningsOfDriver() async {
    DatabaseReference driverEarningsRef = driverRef.child("earnings");

    driverEarningsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map earningsMap = event.snapshot.value as Map;

        // Calcula a última segunda-feira de 6 semanas atrás
        DateTime now = DateTime.now();
        DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1)); // Última segunda-feira
        DateTime referenceDate = lastMonday.subtract(Duration(days: 35)); // 6 semanas atrás

        Map<int, double> weeklyEarnings = {
          for (var i = 0; i < 6; i++) i: 0.0,
        };

        earningsMap.forEach((key, value) {
          double? amount = value['amount'] != null ? double.tryParse(value['amount'].toString()) : null;
          DateTime? earningDate = value['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(value['timestamp'].toString()) ?? 0)
              : null;

          if (amount != null && earningDate != null) {
            // Calcula o número da semana baseado na referenceDate
            int weekNumber = (earningDate.difference(referenceDate).inDays ~/ 7);

            if (weekNumber >= 0 && weekNumber < 6) {
              weeklyEarnings[weekNumber] = (weeklyEarnings[weekNumber] ?? 0.0) + amount;
              print("Processing earning: date=$earningDate, amount=$amount, weekNumber=$weekNumber");
            } else {
              print("Earning out of range: date=$earningDate, amount=$amount, weekNumber=$weekNumber");
            }
          }
        });

        setState(() {
          currentWeekEarnings = weeklyEarnings[0] ?? 0.0;
          lastFiveWeeksEarnings = List.generate(5, (index) => weeklyEarnings[index + 1] ?? 0.0);
          weekDates = List.generate(6, (index) {
            DateTime weekStart = referenceDate.add(Duration(days: index * 7));
            DateTime weekEnd = weekStart.add(Duration(days: 6));
            return "${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}";
          });

          lineChartData = List.generate(6, (index) {
            return FlSpot(index.toDouble(), weeklyEarnings[index] ?? 0.0);
          });
        });
      }
    });
  }





  Widget _buildEarningsDashboard() {
    double maxYValue = lineChartData.isNotEmpty
        ? (lineChartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b).ceilToDouble() + 10).ceilToDouble()
        : 10;

    maxYValue = maxYValue % 10 == 0 ? maxYValue : (maxYValue + (10 - maxYValue % 10)).ceilToDouble();

    return _buildInfoSection("Últimos Ganhos", [
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1F0E), // Verde Escuro
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Ganhos desta Semana:",
              style: TextStyle(
                color: Color(0xFFF2E8D0), // Bege
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "\$ ${(currentWeekEarnings ?? 0.0).toStringAsFixed(2)}",  // Certifique-se de que `currentWeekEarnings` não seja nulo.
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "Ganhos das Últimas 5 Semanas:",
        style: TextStyle(
          color: Color(0xFF0C1F0E), // Verde Escuro
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 120, // Altura reduzida
        child: lastFiveWeeksEarnings.isEmpty
            ? const Center(
          child: Text(
            "Nenhum ganho nas últimas 5 semanas",
            style: TextStyle(
              color: Color(0xFF0C1F0E), // Verde Escuro
            ),
          ),
        )
            : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: lastFiveWeeksEarnings.length,
          itemBuilder: (context, index) {
            return Container(
              width: 180, // Largura reduzida
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1F0E), // Verde Escuro
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Semana ${weekDates[index + 1]}:",
                      style: const TextStyle(
                        color: Color(0xFFF2E8D0), // Bege
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "\$${(index < lastFiveWeeksEarnings.length ? lastFiveWeeksEarnings[index] : 0.0).toStringAsFixed(2)}",  // Certifique-se de que o valor seja numérico.
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "Gráfico de Ganhos (Últimas 6 Semanas):",
        style: TextStyle(
          color: Color(0xFF0C1F0E), // Verde Escuro
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1F0E), // Verde Escuro
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        height: 300, // Altura reduzida
        padding: const EdgeInsets.all(18.0),
        child: lineChartData.isEmpty
            ? const Center(
          child: Text(
            "Nenhum dado para exibir no gráfico",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        )
            : LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    if (value % 10 == 0) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  interval: 1,  // Adicione esta linha para garantir que o título apareça apenas uma vez por semana
                  getTitlesWidget: (value, meta) {
                    final weekIndex = value.toInt();
                    if (weekIndex >= 0 && weekIndex < 6) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 15,
                        child: Transform.translate(
                          offset: const Offset(0, 15),
                          child: Transform.rotate(
                            angle: -0.7854,
                            child: Text(
                              weekDates[weekIndex],
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: lineChartData,
                isCurved: false,
                color: const Color.fromRGBO(185, 150, 100, 1),
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color.fromRGBO(185, 150, 100, 1).withOpacity(0.3),
                ),
              ),
            ],
            minY: 0,
            maxY: maxYValue,
            lineTouchData: LineTouchData(enabled: false),
          ),
        ),
      ),
    ]);
  }



  Widget _buildRecentTrips() {
    return _buildInfoSection("Histórico de Viagens", [
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1F0E), // Verde Escuro
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: recentTrips.isEmpty
              ? [
            const Center(
              child: Text(
                "Nenhuma viagem recente",
                style: TextStyle(
                  color: Color(0xFFF2E8D0), // Bege
                  fontSize: 18,
                ),
              ),
            ),
          ]
              : recentTrips.map((trip) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      trip["pickUpAddress"] ?? "N/A",
                      style: const TextStyle(
                        color: Color(0xFFF2E8D0), // Bege
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      trip["dropOffAddress"] ?? "N/A",
                      style: const TextStyle(
                        color: Color(0xFFF2E8D0), // Bege
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "\$${(trip["fareAmount"] != null ? double.parse(trip["fareAmount"].toString()).toStringAsFixed(2) : '0.00')}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 10),
    ]);
  }

  List<Widget> _buildPhotoWidgets(Map<dynamic, dynamic>? carDetails) {
    List<Widget> photoWidgets = [];
    if (carDetails != null && carDetails.containsKey('images')) {
      Map<dynamic, dynamic> images = carDetails['images'];
      images.forEach((key, value) {
        photoWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Foto ${key.replaceAll('_', ' ')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C1F0E), // Verde Escuro
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: IconButton(
                    icon: const Icon(Icons.download),
                    color: const Color(0xFF0C1F0E), // Verde Escuro
                    onPressed: () {
                      _launchURL(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
    return photoWidgets;
  }

  List<Widget> _buildDocumentWidgets(Map<dynamic, dynamic> driverData) {
    List<Widget> documentWidgets = [];
    if (driverData.containsKey('documents')) {
      Map<dynamic, dynamic> documents = driverData['documents'];
      documents.forEach((key, value) {
        documentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Documento ${key.replaceAll('_', ' ')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C1F0E), // Verde Escuro
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: IconButton(
                    icon: const Icon(Icons.download),
                    color: const Color(0xFF0C1F0E), // Verde Escuro
                    onPressed: () {
                      _launchURL(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
    return documentWidgets;
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
