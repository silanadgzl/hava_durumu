import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _location;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get location => _location;


  void setLocation(double? latitude, double? longitude) {
    _latitude = latitude;
    _longitude = longitude;
    _location = location;
    notifyListeners();
  }
}
