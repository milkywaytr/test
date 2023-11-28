import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gas Station Search',
      home: GasStationSearch(),
    );
  }
}

class GasStationSearch extends StatefulWidget {
  @override
  _GasStationSearchState createState() => _GasStationSearchState();
}

class _GasStationSearchState extends State<GasStationSearch> {
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  String results = '';

  Future<void> searchGasStations() async {
    // Your existing code for searching gas stations
  }

  Future<void> findMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      setState(() {
        results = 'Error getting current location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gas Station Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: radiusController,
              decoration: InputDecoration(labelText: 'Search Radius (in km)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: findMyLocation,
              child: Text('Find My Location'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchGasStations,
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            Text(results),
          ],
        ),
      ),
    );
  }
}
