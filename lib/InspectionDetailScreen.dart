import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_property_inspection/databasehelper.dart';
import 'package:smart_property_inspection/inspectiondata.dart';
import 'package:smart_property_inspection/InspectionForm.dart';


class InspectionDetailScreen extends StatelessWidget {
  final InspectionData inspection;

  const InspectionDetailScreen({super.key, required this.inspection});

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final photos = inspection.photos.split(",");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspection Details"),
        backgroundColor: const Color(0xFF52796F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROPERTY NAME
            Text(
              inspection.propertyName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ADDRESS
            Text(
              inspection.address,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 10),

            // DATE
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 6),
                Text(inspection.dateCreated),
              ],
            ),

            const SizedBox(height: 10),

            // GPS
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  "${inspection.latitude}, ${inspection.longitude}",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // RATING
            Chip(
              label: Text(inspection.rating),
              backgroundColor: Colors.green.withOpacity(0.15),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            const Text(
              "Inspection Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(inspection.description),

            const SizedBox(height: 20),

            // PHOTOS
            const Text(
              "Inspection Photos",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: photos.map((path) {
                final file = File(path);
                return file.existsSync()
                    ? Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.broken_image);
              }).toList(),
            ),

            const SizedBox(height: 30),

            // BUTTONS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => openMap(),
                icon: const Icon(Icons.map),
                label: const Text("Show Location Information"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionFormPage(),
                      settings:
                          RouteSettings(arguments: inspection),
                    ),
                  );
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.edit),
                label: const Text("Update Record"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => deleteRecord(context),
                icon: const Icon(Icons.delete),
                label: const Text("Delete Record"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================
  // ================= FUNCTIONS =====================
  // =================================================

  // OPEN GOOGLE MAP
  void openMap() async {
    final url =
        "https://www.google.com/maps/search/?api=1&query=${inspection.latitude},${inspection.longitude}";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // DELETE RECORD
  void deleteRecord(BuildContext context) async {
    await DatabaseHelper().deleteMyList(inspection.id!);
    Navigator.pop(context, true);
  }
}
