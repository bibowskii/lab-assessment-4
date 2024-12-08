// view/home_view.dart
import 'package:flutter/material.dart';
import '../controller/location_controller.dart';
import '../model/location.dart';
import '../model/address.dart';
import '../model/landmark.dart';
import 'saved_data_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _coordinates;
  String? _address;
  List<String> _selectedLandmarks = [];
  final LocationController _controller = LocationController();

  Future<void> _fetchData() async {
    if (!await _controller.requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    try {
      Location location = await _controller.getCurrentLocation();
      Address address = await _controller.getAddressFromCoordinates(
          location.latitude, location.longitude);
      List<Landmark> landmarks = await _controller.getNearbyLandmarks(
          location.latitude, location.longitude);

      setState(() {
        _coordinates = "${location.latitude}, ${location.longitude}";
        _address = "${address.name}, ${address.locality}, ${address.country}";
      });

      showDialog(
        context: context,
        builder: (_) => SelectLandmarksDialog(
          landmarks: landmarks,
          onSave: (selected) {
            setState(() {
              _selectedLandmarks = selected;
            });
            _controller.saveSelectedLandmarks(selected);
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _navigateToSavedDataView() async {
    List<String> savedLandmarks = await _controller.fetchSavedLandmarks();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedDataView(
          coordinates: _coordinates,
          address: _address,
          landmarks: savedLandmarks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location & Landmarks"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(),
            Icon(
              Icons.location_on,
              color: Colors.blueAccent,
              size: 100,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _fetchData,
              child: Text(
                "Fetch Nearby Landmarks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _navigateToSavedDataView,
              child: Text(
                "Show Saved Landmarks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectLandmarksDialog extends StatefulWidget {
  final List<Landmark> landmarks;
  final void Function(List<String>) onSave;

  SelectLandmarksDialog({required this.landmarks, required this.onSave});

  @override
  _SelectLandmarksDialogState createState() => _SelectLandmarksDialogState();
}

class _SelectLandmarksDialogState extends State<SelectLandmarksDialog> {
  List<bool> _selected;

  _SelectLandmarksDialogState() : _selected = [];

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.landmarks.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Select Landmarks",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueAccent,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: widget.landmarks.asMap().entries.map((entry) {
            final index = entry.key;
            final landmark = entry.value;

            return CheckboxListTile(
              title: Text(
                landmark.name,
                style: TextStyle(color: Colors.black),
              ),
              value: _selected[index],
              onChanged: (value) {
                setState(() {
                  _selected[index] = value ?? false;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
        ),
        TextButton(
          onPressed: () {
            final selectedLandmarks = widget.landmarks
                .asMap()
                .entries
                .where((entry) => _selected[entry.key])
                .map((entry) => entry.value.name)
                .toList();
            widget.onSave(selectedLandmarks);
            Navigator.pop(context);
          },
          child: Text("Save", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
