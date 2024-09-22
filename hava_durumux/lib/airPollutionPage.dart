import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'location_model.dart';

class AirPollutionPage extends StatefulWidget {
  final latitude;
  final longitude;

  const AirPollutionPage({super.key, this.latitude, this.longitude});

  @override
  _AirPollutionPageState createState() => _AirPollutionPageState();
}

class _AirPollutionPageState extends State<AirPollutionPage> {
  double? co;
  double? no2;
  double? o3;
  double? so2;
  double? pm25;
  double? pm10;
  int? aqi;
  var location;

  Future<void> fetchAirPollutionData(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid='));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        aqi = data["list"][0]["main"]["aqi"];
        co = data["list"][0]["components"]["co"];
        no2 = data["list"][0]["components"]["no2"];
        o3 = data["list"][0]["components"]["o3"];
        so2 = data["list"][0]["components"]["so2"];
        pm25 = data["list"][0]["components"]["pm2_5"];
        pm10 = data["list"][0]["components"]["pm10"];
      });
    } else {
      throw Exception('Hava kirliliği verileri yüklenemedi');
    }
  }

  @override
  void initState() {
    super.initState();
    final lat = Provider.of<LocationModel>(context, listen: false).latitude;
    final lon = Provider.of<LocationModel>(context, listen: false).longitude;
    location = Provider.of<LocationModel>(context, listen: false).location;
    if (lat != null && lon != null) {
      fetchAirPollutionData(lat, lon);
    }
  }

  String getAQIExplanation(int? aqi) {
    switch (aqi) {
      case 1:
        return 'İyi';
      case 2:
        return 'Orta';
      case 3:
        return 'Orta';
      case 4:
        return 'Zayıf';
      case 5:
        return 'Çok Zayıf';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Bu, sayfadan geri çıkılmasına izin verir
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Hava Kalitesi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              'assets/gece.jpg', // AppBar için kullanılacak resim dosyasının yolunu girin
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/gece.jpg'),
              fit: BoxFit.cover,
            ),
            color: Colors.transparent,
          ),
          child: Column(
            children: [
              // Sayfanın üst kısmına geniş bir kart ekleyelim
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildWideCard(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: aqi == null
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
                      // buildAirQualityCard('Hava Kalitesi', getAQIExplanation(aqi)),
                      buildAirQualityCard('CO', '$co μg/m3'),
                      buildAirQualityCard('NO2', '$no2 μg/m3'),
                      buildAirQualityCard('O3', '$o3 μg/m3'),
                      buildAirQualityCard('SO2', '$so2 μg/m3'),
                      buildAirQualityCard('PM2.5', '$pm25 μg/m3'),
                      buildAirQualityCard('PM10', '$pm10 μg/m3'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWideCard() {
    String aqiDescription;
    switch (aqi) {
      case 1:
        aqiDescription = "Hava harika; açık havada yürüyüş için mükemmel.";
        break;
      case 2:
        aqiDescription = "Hava kalitesi ortalama; kısa süreli dış mekan aktiviteleri uygun.";

        break;
      case 3:
        aqiDescription =  "Hava biraz kirli; dışarıda kısa bir yürüyüş yapabilirsiniz.";
        break;
      case 4:
        aqiDescription = "Hava kalitesi düşük; dışarı çıkarken dikkatli olun.";
        break;
      case 5:
        aqiDescription = "Hava kalitesi kötü; mümkünse dışarı çıkmaktan kaçının.";
        break;
      default:
        aqiDescription = "Hava kalitesi bilinmiyor.";
        break;
    }

    return Card(
      color: Colors.blue.shade300.withAlpha(100),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.blue.shade100,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hava Kalitesi Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'AQI: ${getAQIExplanation(aqi)} (${aqi ?? 'Bilinmiyor'})',
              style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Konum: $location',
              style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              aqiDescription,
              style: const TextStyle(fontSize: 16,color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAirQualityCard(String title, String value) {
    return WillPopScope(
        onWillPop: () async {
          return true; // Bu, sayfadan geri çıkılmasına izin verir
        },
        child: Card(
          color: Colors.blue.shade200.withAlpha(100),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.blue.shade100,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.white),
                ),
              ],
            ),
          ),

        ));}
}
