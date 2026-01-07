import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_property_inspection/databasehelper.dart';
import 'package:smart_property_inspection/inspectiondata.dart';
import 'package:smart_property_inspection/InspectionForm.dart';

class InspectionDetailScreen extends StatefulWidget {
  final InspectionData inspection;

  const InspectionDetailScreen({super.key, required this.inspection});

  @override
  State<InspectionDetailScreen> createState() =>
      _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final photos = widget.inspection.photos
        .split(",")
        .where((path) => path.trim().isNotEmpty)
        .toList();

    final descLines = widget.inspection.description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        title: const Text(
          "Inspection Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF52796F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //  PROPERTY INFO 
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.inspection.propertyName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.inspection.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // DATE FORMATTED 
                  _infoRow(
                    Icons.access_time,
                    DateFormat("dd MMM yyyy, hh:mm a")
                        .format(DateTime.parse(
                            widget.inspection.dateCreated)),
                  ),

                  const SizedBox(height: 6),
                  _infoRow(
                    Icons.location_on,
                    "${widget.inspection.latitude}, ${widget.inspection.longitude}",
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // RATING SECTION
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAE5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star,
                      size: 18, color: Color(0xFF52796F)),
                  const SizedBox(width: 6),
                  Text(
                    widget.inspection.rating,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F3E46),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //  DESCRIPTION PROPERTY
            const Text(
              "Inspection Description",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _card(
              Column(
                children: descLines.map((text) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF52796F),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            //  PICTURE
            const Text(
              "Inspection Photos",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            if (photos.isNotEmpty)
              Column(
                children: photos.map((path) {
                  final file = File(path);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: file.existsSync()
                          ? Image.file(
                              file,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 220,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                  Icons.image_not_supported),
                            ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // BUTTON
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openMap(),
                    icon: const Icon(Icons.map,
                        color: Color(0xFF52796F)),
                    label: const Text(
                      "Map",
                      style: TextStyle(
                        color: Color(0xFF52796F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF52796F)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const InspectionFormPage(),
                          settings: RouteSettings(
                              arguments: widget.inspection),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.edit,
                        color: Colors.white),
                    label: const Text(
                      "Update",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF52796F),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => confirmDelete(context),
                    icon: const Icon(Icons.delete,
                        color: Colors.white),
                    label: const Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.black45),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  // TO OPEN MAP
  void openMap() async {
    final uri = Uri.parse(
      "geo:${widget.inspection.latitude},${widget.inspection.longitude}?q=${widget.inspection.latitude},${widget.inspection.longitude}",
    );

    if (!await launchUrl(uri,
        mode: LaunchMode.externalApplication)) {
      final fallback = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.inspection.latitude},${widget.inspection.longitude}",
      );
      await launchUrl(fallback,
          mode: LaunchMode.externalApplication);
    }
  }

  // DELETE 
  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Inspection"),
        content:
            const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper()//DELETE DATA FROM DB
                  .deleteMyList(widget.inspection.id);
              Navigator.pop(context, true);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}
