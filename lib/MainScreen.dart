import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_property_inspection/InspectionForm.dart';
import 'package:smart_property_inspection/InspectionDetailScreen.dart';
import 'package:smart_property_inspection/databasehelper.dart';
import 'package:smart_property_inspection/inspectiondata.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<InspectionData> inspectionList = [];
  final TextEditingController searchController = TextEditingController();

  bool isSearching = false;
  int limit = 20;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {
    inspectionList =
        await DatabaseHelper().getMyListsPaginated(limit, 0);
    if (mounted) setState(() {});
  }

  // ================= DELETE DIALOG =================
  void deleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Inspection"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper().deleteMyList(id);
              if (mounted) Navigator.pop(context);
              loadData();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Inspection"),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Property name, address or description",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final keyword = searchController.text.trim();
              if (keyword.isEmpty) return;

              inspectionList =
                  await DatabaseHelper().searchMyList(keyword);

              if (mounted) {
                setState(() => isSearching = true);
                Navigator.pop(context);
              }
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF52796F),
        child: const Icon(Icons.add_home_work, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InspectionFormPage(),
            ),
          );
          loadData();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6F5), Color(0xFFDCE5E3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Property Inspections",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3E46),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Inspection records stored locally",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // SEARCH BAR
                  GestureDetector(
                    onTap: showSearchDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search property or description...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isSearching)
                    TextButton(
                      onPressed: () {
                        isSearching = false;
                        searchController.clear();
                        loadData();
                      },
                      child: const Text("← Back to all inspections"),
                    ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: inspectionList.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: inspectionList.length,
                      itemBuilder: (context, index) {
                        final item = inspectionList[index];

                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InspectionDetailScreen(
                                  inspection: item,
                                ),
                              ),
                            );

                            if (result == true) {
                              loadData();
                            }
                          },
                          child: _inspectionCard(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _inspectionCard(InspectionData item) {
    final firstImage = item.photos.isNotEmpty
        ? item.photos.split(",")[0]
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF52796F),
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(18)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: _loadImage(firstImage),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ratingChip(item.rating),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              onPressed: () =>
                                  deleteDialog(item.id),
                            ),
                          ],
                        ),
                        Text(
                          item.propertyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.dateCreated,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RATING CHIP =================
  Widget _ratingChip(String rating) {
    Color color;
    switch (rating) {
      case "Excellent":
        color = Colors.green;
        break;
      case "Good":
        color = Colors.blue;
        break;
      case "Fair":
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rating,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ================= IMAGE =================
  Widget _loadImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    final file = File(path);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.broken_image);
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined,
              size: 90, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No inspection records",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("Tap + to add a new inspection"),
        ],
      ),
    );
  }
}
