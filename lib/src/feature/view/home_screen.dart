import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../outer_layer/model/scanned_result.dart';
import '../../widgets/recognition_view.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late XFile? pickImage;
  late String resultText;
  List<ScannedResult> scannedResults = [];

  @override
  void initState() {
    pickImage = null;
    resultText = '';
    super.initState();
    loadScannedResults();
  }

  Future<void> getImage(ImageSource imgSource) async {
    try {
      pickImage = (await ImagePicker().pickImage(source: imgSource))!;
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  // Update the local list and UI
  Future<void> saveScannedResult(ScannedResult scannedResult) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scannedResultsJson =
        prefs.getStringList('scannedResults') ?? [];
    scannedResultsJson.add(jsonEncode(scannedResult.toJson()));
    await prefs.setStringList('scannedResults', scannedResultsJson);
    setState(() {
      scannedResults.add(scannedResult);
    });
  }

  // Get the list of results from SharedPreferences
  Future<void> loadScannedResults() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scannedResultsJson =
        prefs.getStringList('scannedResults') ?? [];
    setState(() {
      scannedResults = scannedResultsJson
          .map((result) => ScannedResult.fromJson(jsonDecode(result)))
          .toList();
    });
  }

  //clear the data's
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      scannedResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OCR APP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        centerTitle: true,
        elevation: 24,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'clear') {
                clearData();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear Data'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scannedResults.length,
              itemBuilder: (context, index) {
                final result = scannedResults[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ExpansionTile(
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text('ID: ${result.id}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          result.resultText,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                await getImage(ImageSource.gallery);
                if (pickImage != null) {
                  resultText = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecognitionPage(xFile: pickImage!),
                    ),
                  );
                  // Save the scanned result
                  final imageCount =
                      scannedResults.length + 1; // To increment the image count
                  final newResult = ScannedResult(
                    id: 'Scanned Image $imageCount - ${TimeOfDay.now().format(context)}',
                    resultText: resultText,
                  );
                  await saveScannedResult(newResult);
                  setState(() {});
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.photo_library_outlined),
                  SizedBox(width: 8),
                  Text('Gallery'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await getImage(ImageSource.camera);
                if (pickImage != null) {
                  resultText = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecognitionPage(xFile: pickImage!),
                    ),
                  );
                  // Save the scanned result
                  final imageCount = scannedResults.length + 1;
                  final newResult = ScannedResult(
                    id: 'Scanned Image $imageCount - ${TimeOfDay.now().format(context)}',
                    resultText: resultText,
                  );

                  await saveScannedResult(newResult);
                  setState(() {});
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined),
                  SizedBox(width: 8),
                  Text('Camera'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
