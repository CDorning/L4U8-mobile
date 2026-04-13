import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'camera_screen.dart';
import 'district_results_screen.dart';
import 'material_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  String _gpsStatus = 'Checking GPS for current district...';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // MERIT FEATURE: Use GPS to get the device's current geo-location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _gpsStatus = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _gpsStatus = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _gpsStatus = 'Location permissions are permanently denied.';
      });
      return;
    }
    
    // For this prototype, we'll just confirm that we can get a location.
    // A full implementation would compare these coords to a list of district boundaries.
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
         _gpsStatus = 'GPS Active (Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)})';
      });
    } catch(e) {
       setState(() {
         _gpsStatus = 'Could not get location.';
       });
    }
  }

  void _searchByDistrict() {
    if (_districtController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DistrictResultsScreen(districtName: _districtController.text),
        ),
      );
    }
  }

  void _searchByMaterial() {
    if (_materialController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaterialResultsScreen(materialName: _materialController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centrala Recycling Guide'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ESSENTIAL FEATURE 1: Search by district
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Search by your District',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchByDistrict,
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _searchByDistrict(),
              ),
              const SizedBox(height: 20),
      
              // ESSENTIAL FEATURE 2: Search by material
              TextField(
                controller: _materialController,
                decoration: InputDecoration(
                  labelText: 'Search by Recyclable Item',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchByMaterial,
                  ),
                  border: const OutlineInputBorder(),
                ),
                 onSubmitted: (_) => _searchByMaterial(),
              ),
              const SizedBox(height: 40),
      
              // ESSENTIAL FEATURE 3: Camera lookup
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Is this recyclable? Ask the CEA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // MERIT FEATURE: GPS status display
              const Divider(),
              const SizedBox(height: 10),
              Text(
                _gpsStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}