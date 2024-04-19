import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
  import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:weather/weather.dart';


class Getaddress extends StatefulWidget {
  const Getaddress({super.key});

  @override
  State<Getaddress> createState() => _GecodeState();
}

class _GecodeState extends State<Getaddress> {
      geocoding.Location? location;
          var INPUT = TextEditingController();
          Weather? weather;
final WeatherFactory wt=WeatherFactory("7ea800c5b47ff076c8e5798ccab58814");
void getGeo() async {
  if(INPUT.text.isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please first input an address'))
    );
    return; // Return to avoid further execution
  }
  
  try {
    List<geocoding.Location> locations = await geocoding.locationFromAddress(INPUT.text);
    if (locations.isNotEmpty) {
      setState(() {
        location = locations.first;
      });
      weather = await wt.currentWeatherByLocation(location!.latitude, location!.longitude);
      setState(() {
        // Update the UI if necessary
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No location found for the entered address'))
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}'))
    );
  }
}


    
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Find Location"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 16),
          TextField(
            controller: INPUT,
            decoration: InputDecoration(
              labelText: "Enter Address",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getGeo,
                  child: Text('LOAD GEOCODE', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (location != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Center(child: Text('Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                Center(child: Text('Latitude: ${location!.latitude}')),
                Center(child: Text('Longitude: ${location!.longitude}')),
              ],
            ),
          if (weather != null) ...[
            SizedBox(height: 16),
            Text('Weather Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Temperature: ${weather!.temperature?.celsius}°C'),
            Text('Description: ${weather!.weatherMain}'),
            Text('Detailed Description: ${weather!.weatherDescription}'),
            Text('Wind Speed: ${weather!.windSpeed} m/s'),
          ],
        ],
      ),
    ),
  );
}

}