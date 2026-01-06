import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_property_inspection/databasehelper.dart';
import 'package:smart_property_inspection/inspectiondata.dart';


class InspectionFormPage extends StatefulWidget {
  const InspectionFormPage({super.key});

  @override
  State<InspectionFormPage> createState() => _InspectionFormPageState();
}

class _InspectionFormPageState extends State<InspectionFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final List<File> images = [];

  String rating = "Good";
  double? latitude;
  double? longitude;

  InspectionData? editInspection;
  late String dateCreated;

  @override
  void initState() {
    super.initState();
    dateCreated =
        DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now());
    _getLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is InspectionData && editInspection == null) {
      editInspection = args;

      nameController.text = args.propertyName;
      addressController.text = args.address;
      descriptionController.text = args.description;
      rating = args.rating;
      latitude = args.latitude;
      longitude = args.longitude;
      dateCreated = args.dateCreated;

      images.clear();
      for (String path in args.photos.split(",")) {
        if (path.isNotEmpty) images.add(File(path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editInspection == null
            ? "New Inspection"
            : "Update Inspection"),
        backgroundColor: const Color(0xFF52796F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Property Name",
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Property Address",
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              latitude == null
                  ? "Detecting GPS location..."
                  : "GPS: $latitude , $longitude",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Inspection Description",
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: rating,
              decoration: const InputDecoration(
                labelText: "Overall Rating",
              ),
              items: const [
                DropdownMenuItem(value: "Excellent", child: Text("Excellent")),
                DropdownMenuItem(value: "Good", child: Text("Good")),
                DropdownMenuItem(value: "Fair", child: Text("Fair")),
                DropdownMenuItem(value: "Poor", child: Text("Poor")),
              ],
              onChanged: (val) => setState(() => rating = val!),
            ),
            const SizedBox(height: 16),
            Text("Photos (${images.length}/3 minimum)"),
            Wrap(
              spacing: 8,
              children: images
                  .map((img) => Image.file(
                        img,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ))
                  .toList(),
            ),
            ElevatedButton.icon(
              onPressed: () => addImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Add Photo"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveInspection,
                child: const Text("Save Inspection"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= METHODS =================

  Future<void> _getLocation() async {
    LocationPermission permission =
        await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<void> addImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => images.add(File(picked.path)));
    }
  }

  Future<void> saveInspection() async {
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        images.length < 3 ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    List<String> paths = [];

    for (File img in images) {
      if (img.path.contains(dir.path)) {
        paths.add(img.path);
      } else {
        final name = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final path = "${dir.path}/$name";
        await img.copy(path);
        paths.add(path);
      }
    }

    final inspection = InspectionData(
      editInspection?.id ?? 0,
      nameController.text.trim(),
      addressController.text.trim(),
      descriptionController.text.trim(),
      rating,
      latitude!,
      longitude!,
      dateCreated,
      paths.join(","),
    );

    if (editInspection == null) {
      await DatabaseHelper().insertMyList(inspection);
    } else {
      await DatabaseHelper().updateMyList(inspection);
    }

    if (mounted) Navigator.pop(context);
  }
}
