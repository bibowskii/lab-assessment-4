// view/saved_data_view.dart
import 'package:flutter/material.dart';

class SavedDataView extends StatelessWidget {
  final String? coordinates;
  final String? address;
  final List<String> landmarks;

  SavedDataView({
    required this.coordinates,
    required this.address,
    required this.landmarks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Data"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coordinates != null)
              Text(
                "Coordinates: $coordinates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            if (address != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Address: $address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            SizedBox(height: 20),
            Text(
              "Saved Landmarks:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (landmarks.isNotEmpty)
              ...landmarks.map((landmark) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "- $landmark",
                  style: TextStyle(fontSize: 16),
                ),
              )),
            if (landmarks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "No saved landmarks.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
