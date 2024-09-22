import 'package:flutter/material.dart';
import 'degisken.dart';

Widget buildAdditionalInfoCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Card(
            color: Colors.white24,
            shadowColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 5,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(color: Colors.transparent,shadowColor: Colors.blue.shade50,
                      child: Container(
                        padding: const EdgeInsets.only(top: 6,bottom: 6,right: 6,left: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset("assets/sunrise.png",width: 35,height: 35),
                                  //    Text("GünD", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),
                                  Text("$formattedSunriseTime", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),]),
                            const Divider(color: Colors.lime, thickness: 1),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Bulut", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),
                                Text("%$clouds", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),

                              ],
                            ),



                            const Divider(color: Colors.lime, thickness: 1),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Basınç", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),
                                  Text("${mbar}mbar", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),]),
                            const Divider(color: Colors.lime, thickness: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(color: Colors.transparent,shadowColor: Colors.blue.shade50,
                    child: Container(
                      padding: const EdgeInsets.only(top: 6,bottom: 6,right: 6,left: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/sunset.png",width: 35,height: 35),

                                Text("$formattedSunsetTime", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),]),


                          const Divider(color: Colors.lime, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Nem", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),
                              Text("%$humidity", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),

                            ],
                          ),
                          const Divider(color: Colors.lime, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Hissedilen", style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),
                              Text("${feels_like.round()}°C", style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600)),

                            ],
                          ),
                          const Divider(color: Colors.lime, thickness: 1),
                        ],
                      ),
                    ),
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