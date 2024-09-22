import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hava_durumux/daily_weather_card.dart';
import 'package:hava_durumux/geocolator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'airPollutionPage.dart';
import 'buildAdditionalInfoCard.dart';
import 'degisken.dart';
import 'location_model.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key,});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon();
    getDailyForeCastByLatLon();
  }

  Future<void> getDevicePosition()async{
    try{
      devicePosition = await determinePosition();
    }catch(e){
    }
  }

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric&lang=tr"));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed["main"]["temp"];
      location = locationDataParsed["name"];
      code = locationDataParsed["weather"][0]["main"];
      description = locationDataParsed["weather"][0]["description"];
      mbar = locationDataParsed["main"]["pressure"];
      humidity = locationDataParsed["main"]["humidity"];
      icon = locationDataParsed["weather"].first["icon"];
      clouds = locationDataParsed["clouds"]["all"];
      sunrise =locationDataParsed["sys"]["sunrise"].round();
      sunset =locationDataParsed["sys"]["sunset"].round();
      lon =locationDataParsed["coord"]["lon"];
      lat =locationDataParsed["coord"]["lat"];
      feels_like= locationDataParsed["main"]["feels_like"];

      // Provider kullanarak modeldeki değerleri güncelle
      Provider.of<LocationModel>(context, listen: false).setLocation(lat!, lon!,location!);

    });



    setState(() {
      // Timestamp'ı DateTime nesnesine çeviriyoruz
      DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
      DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);

// Sadece saat ve dakika olarak string formatında almak
      formattedSunsetTime = "${sunsetTime.hour.toString().padLeft(2, '0')}:${sunsetTime.minute.toString().padLeft(2, '0')}";
      formattedSunriseTime = "${sunriseTime.hour.toString().padLeft(2, '0')}:${sunriseTime.minute.toString().padLeft(2, '0')}";

    });


  }

  void navigateToAirPollutionPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirPollutionPage(
          latitude: lat ?? devicePosition!.latitude,
          longitude: lon ?? devicePosition!.longitude,
        ),
      ),
    );
  }


  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric&lang=tr"));
      final locationDataParsed = jsonDecode(locationData.body);




      setState(() {
        temperature = locationDataParsed["main"]["temp"];
        location = locationDataParsed["name"];
        code = locationDataParsed["weather"][0]["main"];
        description = locationDataParsed["weather"][0]["description"];
        mbar = locationDataParsed["main"]["pressure"];
        feels_like= locationDataParsed["main"]["feels_like"];
        icon = locationDataParsed["weather"].first["icon"];
        sunrise =locationDataParsed["sys"]["sunrise"].round();
        sunset =locationDataParsed["sys"]["sunset"].round();
        clouds = locationDataParsed["clouds"]["all"];
        humidity = locationDataParsed["main"]["humidity"];


        setState(() {
          // Timestamp'ı DateTime nesnesine çeviriyoruz
          DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
          DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);

// Sadece saat ve dakika olarak string formatında almak
          formattedSunsetTime = "${sunsetTime.hour.toString().padLeft(2, '0')}:${sunsetTime.minute.toString().padLeft(2, '0')}";
          formattedSunriseTime = "${sunriseTime.hour.toString().padLeft(2, '0')}:${sunriseTime.minute.toString().padLeft(2, '0')}";
        });
      });



    }}

  Future<void> getDailyForeCastByLatLon() async {
    var foreCastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric&lang=tr"));
    var foreCastDataParsed = jsonDecode(foreCastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();
    maxTempList.clear();
    minTempList.clear();
    cloudList.clear();
    humidityList.clear();
    descriptionList.clear();

    setState(() {
      for (int i = 7; i < 40; i += 8) {
        temperatures.add((foreCastDataParsed["list"][i]["main"]["temp"]).toDouble());
        icons.add(foreCastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(foreCastDataParsed["list"][i]["dt_txt"]);
        cloudList.add(foreCastDataParsed["list"][i]["clouds"]["all"]);
        humidityList.add(foreCastDataParsed["list"][i]["main"]["humidity"]);
        descriptionList.add(foreCastDataParsed["list"][i]["weather"][0]["description"]);
      }





      setState(() {

        // 40 elemanlı JSON verisini temp_min değerlerini çekip listeye ekleme
        for (int i = 0; i < 40; i++) {
          tempMinList.add(foreCastDataParsed["list"][i]["main"]["temp_min"].toString());

        }

        // 8'er 8'er gruplama

        for (int i = 0; i < tempMinList.length; i += 8) {
          dailyGroups.add(tempMinList.sublist(i, i + 8));
        }

        // Her grup için değerleri yuvarlayıp yazdırma
        for (int i = 0; i < dailyGroups.length; i++) {
          dailyHours = dailyGroups[i].map((temp) {
            tempValue  = double.parse(temp);
            return tempValue!.toStringAsFixed(0); // Ondalık basamağa yuvarlama
          }).toList();

          // Yuvarlanmış sıcaklıkları double'a çevir ve min/max değerlerini hesapla
          List<double> dailyTemps = dailyHours.map((temp) => double.parse(temp)).toList();
          maxTemp= dailyTemps.reduce((a, b) => a > b ? a : b);
          minTemp = dailyTemps.reduce((a, b) => a < b ? a : b);
          print("bugun ${minTemp}");
        };





      }




      );});
  }

  Future<void> getDailyForeCastByLocation() async {

    var foreCastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric&lang=tr"));
    var foreCastDataParsed = jsonDecode(foreCastData.body);



    temperatures.clear();
    icons.clear();
    dates.clear();
    maxTempList.clear();
    minTempList.clear();
    tempMinList.clear();
    dailyGroups.clear();
    cloudList.clear();
    humidityList.clear();
    descriptionList.clear();


    setState(() {
      for (int i = 7; i < 40; i += 8) {
        temperatures.add((foreCastDataParsed["list"][i]["main"]["temp"]).toDouble());
        icons.add(foreCastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(foreCastDataParsed["list"][i]["dt_txt"]);
        cloudList.add(foreCastDataParsed["list"][i]["clouds"]["all"]);  // Bulut değerini ekleyin
        humidityList.add(foreCastDataParsed["list"][i]["main"]["humidity"]);
        descriptionList.add(foreCastDataParsed["list"][i]["weather"][0]["description"]);


      }
      print("humidityList: Farklı şehir: $humidityList");

    });

      setState(() {

      // 40 elemanlı JSON verisini temp_min değerlerini çekip listeye ekleme
      for (int i = 0; i < 40; i++) {
        tempMinList.add(foreCastDataParsed["list"][i]["main"]["temp_min"].toString());



      }

      // 8'er 8'er gruplama

      for (int i = 0; i < tempMinList.length; i += 8) {
        dailyGroups.add(tempMinList.sublist(i, i + 8));
      }

      // Her grup için değerleri yuvarlayıp yazdırma
      for (int i = 0; i < dailyGroups.length; i++) {
        dailyHours = dailyGroups[i].map((temp) {
          tempValue  = double.parse(temp);
          return tempValue!.toStringAsFixed(0); // Ondalık basamağa yuvarlama
        }).toList();

        // Yuvarlanmış sıcaklıkları double'a çevir ve min/max değerlerini hesapla
        List<double> dailyTemps = dailyHours.map((temp) => double.parse(temp)).toList();
        maxTemp= dailyTemps.reduce((a, b) => a > b ? a : b);
        minTemp = dailyTemps.reduce((a, b) => a < b ? a : b);
        print("bugun ${minTemp}");
      }


    }
    );
  }

  @override
  Widget build(BuildContext context) {
    var lonx;
    var latx;

    lon=lonx;
    lat=latx;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          //image: AssetImage('assets/${code ?? 'default'}.jpg'),
          image: AssetImage('assets/gece.jpg'),

          fit: BoxFit.cover,
        ),
        color: Colors.transparent,
      ),
      child: (temperature == null || devicePosition == null || icons.isEmpty || dates.isEmpty || temperatures.isEmpty || descriptionList.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [Column(
            children: [
              Card(
                color: Colors.white60,
                shadowColor: Colors.white,
                elevation: 7,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Ara",
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // Kenarlardan boşluk bırakır
                        ),
                        onChanged: (value) {
                          selectedCity = value; // TextField'daki değeri güncelle
                        },
                      ),
                    ),

                    IconButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        // API'den veriyi çekin
                        var response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=$key&units=metric&lang=tr"));

                        if (response.statusCode == 200) {
                          // Başarılıysa şehir ismini güncelleyin ve veri çekin
                          setState(() {
                            location = selectedCity; // Şehir ismini güncelle
                          });

                          await getLocationDataFromAPI(); // Yeni şehir verisini çek
                          await getDailyForeCastByLocation(); // Günlük hava tahmini verisini çek
                        } else {
                          // API'den geçersiz bir yanıt alırsak, mevcut şehir ismini değiştirmeyin ve Snackbar gösterin
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.blueGrey,
                              content: Text("Lütfen geçerli bir şehir girin!"),
                            ),
                          );
                          // Mevcut şehir bilgisi değişmeden kalır
                        }
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: 150,width: 130,
                  child: Image.asset("assets/$icon.png")
              ),
              Text(
                  "${temperature?.round().toString()}°C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold
                  )
              ),
              Text(
                  description,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 20
                  )
              ),
              Text(
                  location,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 30
                  )
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStatePropertyAll(Colors.white24)
                ),
                onPressed: () async {

                  await getLocationDataFromAPI();
                  await getDailyForeCastByLocation();

                  // Eğer konum bilgisi varsa, sayfa geçişini yap
                  if (devicePosition != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AirPollutionPage(
                          latitude: lat ?? devicePosition!.latitude,
                          longitude: lon ?? devicePosition!.longitude,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cihazın konum bilgisi alınamadı!"),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/air.png", width: 24, height: 24, color: Colors.white30), // Görüntüyü buraya ekliyoruz
                    const SizedBox(width: 8), // Görüntü ile metin arasına boşluk ekliyoruz
                    const Text("Hava Kalitesi", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)), // Metin etiketini buraya ekliyoruz
                  ],
                ),
              ),
              SizedBox(height: 50),
              buildWeatherCard(context),
              buildAdditionalInfoCard(context), // Yeni eklenen card
            ],
          ),
        ]),
      ),
    );
  }

  Widget buildWeatherCard(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    setState(() {
      for (int i = 0; i < dailyGroups.length; i++) {
        List<double> dailyTemps = dailyGroups[i].map((temp) => double.parse(temp)).toList();

        maxTemp = dailyTemps.reduce((a, b) => a > b ? a : b);
        minTemp = dailyTemps.reduce((a, b) => a < b ? a : b);

        maxTempList.add(maxTemp!);
        minTempList.add(minTemp!);
      }

      for (int i = 0; i < 5; i++) {
        cards.add(DailyWeatherCard(
          description: descriptionList[i],
          icon: icons[i],
          date: dates[i],
          maxTempx: maxTempList[i],
          minTempx: minTempList[i],
          cloud: cloudList[i],  // Yeni eklenen bulut değeri
          humidity: humidityList[i],
        ));
      }

    });


    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.25,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: cards,
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}


