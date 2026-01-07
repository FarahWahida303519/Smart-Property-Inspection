import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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

  // IMAGE 
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

    // TO store sortable ISO date (TEXT)SINCE DATE IN TEXT
    dateCreated = DateTime.now().toIso8601String();

    _getLocation(); // auto-detect GPS
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

      // keep original date when editing
      dateCreated = args.dateCreated;

      images.clear();
      for (String path in args.photos.split(",")) {
        if (path.trim().isNotEmpty) {
          images.add(File(path));
        }
      }
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F5),
      appBar: AppBar(
        title: Text(
          editInspection == null ? "New Inspection" : "Update Inspection",//TO DETERMINE WHEN ITS OPEN THE FORM ETIHER FOR ADD NEW PROPERTY OR UPDATE NEW DATA 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF52796F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
              style: const TextStyle(color: Colors.black54),
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
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images
                  .map((img) => Image.file(
                        img,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
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

  // GPS 
  Future<void> _getLocation() async {
    LocationPermission permission =
        await Geolocator.requestPermission();
//PERMISSIONS TO ACCESS THE LOCATION 
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  // IMAGE PICK 
  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              pickAndCrop(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickAndCrop(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> pickAndCrop(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: const Color(0xFF52796F),
          toolbarWidgetColor: Colors.white,
        ),
      ],
    );

    if (cropped != null) {
      setState(() => images.add(File(cropped.path)));
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
      await DatabaseHelper().insertMyList(inspection);//TO INSERT A NEW DATA
    } else {
      await DatabaseHelper().updateMyList(inspection);//TO UPDATE THE NEW DETAILS IN PROPERTIES LIST
    }

    if (mounted) Navigator.pop(context);
  }
}
