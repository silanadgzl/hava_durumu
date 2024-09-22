import 'package:flutter/foundation.dart';

class LocationModel with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _location;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get location => _location;


  void setLatitude(double latitude) {
    _latitude = latitude;
    notifyListeners();
  }

  void setLongitude(double longitude) {
    _longitude = longitude;
    notifyListeners();
  }

  void setLocation(double latitude, double longitude, String location) {
    _latitude = latitude;
    _longitude = longitude;
    _location = location;
    notifyListeners();
  }
}
