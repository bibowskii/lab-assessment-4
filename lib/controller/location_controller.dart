import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/location.dart'; // Your custom Location model
import '../model/landmark.dart';
import '../model/address.dart';

class LocationController {
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Location> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return Location(latitude: position.latitude, longitude: position.longitude);
  }

  Future<Address> getAddressFromCoordinates(double latitude, double longitude) async {
    List<geocoding.Placemark> placemarks =
    await geocoding.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      return Address(
        name: placemark.name ?? 'Unknown',
        locality: placemark.locality ?? 'Unknown',
        country: placemark.country ?? 'Unknown',
      );
    }
    return Address(name: 'Unknown', locality: 'Unknown', country: 'Unknown');
  }

  Future<List<Landmark>> getNearbyLandmarks(double latitude, double longitude) async {
    List<geocoding.Placemark> placemarks =
    await geocoding.placemarkFromCoordinates(latitude, longitude);
    return placemarks
        .map((place) => Landmark(name: place.name ?? 'Unknown', locality: place.locality ?? 'Unknown'))
        .toList();
  }

  Future<void> saveSelectedLandmarks(List<String> selectedLandmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_landmarks', selectedLandmarks);
  }

  Future<List<String>> fetchSavedLandmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_landmarks') ?? [];
  }
}
