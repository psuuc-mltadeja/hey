import 'package:flutter/material.dart';
import 'package:tadeja_assignment6/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class CurrentLocationScreen extends StatefulWidget {
  CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? position;
  String address = "";
  Weather? weather;
  final WeatherFactory wt = WeatherFactory("7ea800c5b47ff076c8e5798ccab58814");
  @override
  void initState() {
    super.initState();
    getCurrentLoc();
  }

  Future<bool> checkServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Location services is disabled. Please enable it in settings."),
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permission is denied. Please accept the permission to use our app.'),
          ),
        );
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change it in settings to continue.'),
        ),
      );
      return false;
    }

    return true;
  }

  void getCurrentLoc() async {
    if (!await checkServicePermission()) {
      return;
    }
    Position newPosition = await Geolocator.getCurrentPosition();
    setState(() {
      position = newPosition;
    });

    // Convert coordinates to address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      setState(() {
        address =
            " ${placemark.subLocality} ${placemark.locality ?? ''}, ${placemark.subAdministrativeArea ?? ''}, ${placemark.country ?? ''}";
        print(address);
      });
      weather = await wt.currentWeatherByLocation(
          position!.latitude, position!.longitude);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigation"),
        actions: [
          TextButton.icon(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Getaddress()));
              },
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              label: Text(
                "",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: getCurrentLoc,
              child: Text(
                "LOAD CURRENT LOCATION",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 16),
            if (position != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        "Location",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Center(
                                  child: Text(
                                'Latitude',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              Center(child: Text('${position!.latitude}')),
                            ],
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Center(
                                  child: Text(
                                'Longitude',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              Center(child: Text('${position!.longitude}')),
                            ],
                          ),
                        ],
                      ),
                      Center(child: Text('Accuracy: ${position!.accuracy}')),
                      Center(child: Text('Altitude: ${position!.altitude}')),
                      SizedBox(height: 10,),
                      Center(child: Text('Address: $address')),
                      SizedBox(
                        height: 10,
                      ),
                      if (weather != null) ...[
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text('Weather Information',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                        Center(child: Text('Temperature: ${weather!.temperature?.celsius}°C')),
                        Center(child: Text('Description: ${weather!.weatherMain}')),
                        Center(
                          child: Text(
                              'Detailed Description: ${weather!.weatherDescription}'),
                        ),
                        Center(child: Text('Wind Speed: ${weather!.windSpeed} m/s')),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
