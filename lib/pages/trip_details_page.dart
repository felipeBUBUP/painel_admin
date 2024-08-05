import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../methods/common_methods.dart';

class TripDetailsPage extends StatefulWidget {
  final Map tripData;

  const TripDetailsPage({Key? key, required this.tripData}) : super(key: key);

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final DatabaseReference tripRef = FirebaseDatabase.instance.ref().child("agendamentosPendentes");
  CommonMethods cMethods = CommonMethods();

  void markAsExecuted() {
    tripRef.child(widget.tripData["key"]).update({
      "status": "Concluído",
    }).then((_) {
      Navigator.pop(context);
    });
  }

  void markAsNotExecuted() {
    tripRef.child(widget.tripData["key"]).update({
      "status": "Agendado",
    }).then((_) {
      Navigator.pop(context);
    });
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Detalhes da Viagem",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              buildPdfRow("ID da Viagem", widget.tripData["key"].toString()),
              buildPdfRow("ID do Usuário", widget.tripData["userID"].toString()),
              buildPdfRow("Usuário", widget.tripData["userName"].toString()),
              buildPdfRow("Telefone do Usuário", widget.tripData["userPhone"].toString()),
              buildPdfRow("Partida", widget.tripData["pickUpPlaceName"].toString()),
              buildPdfRow("Destino", widget.tripData["destinationPlaceName"].toString()),
              buildPdfRow("Data/Hora", widget.tripData["scheduledDateTime"].toString()),
              buildPdfRow("Tipo de Serviço", widget.tripData["serviceType"].toString()),
              buildPdfRow("Status", widget.tripData["status"].toString()),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 16),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Viagem"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: generatePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildDetailRow("ID da Viagem", widget.tripData["key"].toString()),
                    buildDetailRow("ID do Usuário", widget.tripData["userID"].toString()),
                    buildDetailRow("Usuário", widget.tripData["userName"].toString()),
                    buildDetailRow("Telefone do Usuário", widget.tripData["userPhone"].toString()),
                    buildDetailRow("Partida", widget.tripData["pickUpPlaceName"].toString()),
                    buildDetailRow("Destino", widget.tripData["destinationPlaceName"].toString()),
                    buildDetailRow("Data/Hora", widget.tripData["scheduledDateTime"].toString()),
                    buildDetailRow("Tipo de Serviço", widget.tripData["serviceType"].toString()),
                    buildDetailRow("Status", widget.tripData["status"].toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.tripData["status"] == "Agendado" ? markAsExecuted : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    "Marcar como Concluída",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.tripData["status"] == "Concluído" ? markAsNotExecuted : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    "Marcar como Não Concluída",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
