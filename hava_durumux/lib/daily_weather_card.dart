import 'package:flutter/material.dart';
import 'package:hava_durumux/homePage.dart';
import 'package:marquee/marquee.dart';

class DailyWeatherCard extends StatefulWidget {
  final String icon;
  final String date;
  final double maxTempx;
  final double minTempx;
  final int cloud;
  final int humidity;
  final String description;

  const DailyWeatherCard({
    Key? key,
    required this.description,
    required this.icon,
    required this.date,
    required this.maxTempx,
    required this.minTempx,
    required this.cloud,
    required this.humidity,
  }) : super(key: key);

  @override
  State<DailyWeatherCard> createState() => _DailyWeatherCardState();
}

class _DailyWeatherCardState extends State<DailyWeatherCard> {
  String? weekday;

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"];
    weekday = weekdays[DateTime.parse(widget.date).weekday - 1];

    return Padding(
      padding: const EdgeInsets.all(4.0), // Card'lar arasına mesafe ekleyin
      child: Card(
        color: Colors.blue.shade200.withAlpha(100),
        shadowColor: Colors.white,
        surfaceTintColor: Colors.blue.shade100,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: GestureDetector(
          onTap: () {
            _showDetailDialog(context);
          },
          child: SizedBox(
            height: 120,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(height: 80,width: 50,child: Image.asset("assets/${widget.icon}.png")),
                ),
                Text(
                  "$weekday",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final text = widget.description;
                    final textStyle = const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    );

                    final textSpan = TextSpan(text: text, style: textStyle);
                    final textPainter = TextPainter(
                      text: textSpan,
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);

                    if (textPainter.didExceedMaxLines) {
                      return SizedBox(
                        height: 20,
                        child: Marquee(
                          text: text,
                          style: textStyle,
                          scrollAxis: Axis.horizontal,
                          blankSpace: 20.0,
                          velocity: 50.0,
                          pauseAfterRound: Duration(seconds: 1),
                          startPadding: 10.0,
                          accelerationDuration: Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration: Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      );
                    } else {
                      return Text(text, style: textStyle);
                    }
                  },
                ),
                Text(
                  "${widget.maxTempx.round()}/${widget.minTempx.round()} ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade200,
          shadowColor: Colors.white,
          elevation: 5,
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  color: Colors.blueGrey.shade400,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 60,width: 60,child: Image.asset("assets/${widget.icon}.png")),
                      const Divider(color: Colors.grey, thickness: 1),
                      Text(
                        "$weekday",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      Text(
                        "${widget.maxTempx.round()}°/${widget.minTempx.round()}°",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      Text(
                        "Bulut: %${widget.cloud}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      Text(
                        "Nem: %${widget.humidity}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
