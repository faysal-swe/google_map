import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../../data/services/google_map_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late GoogleMapController mapController;
  Location location = Location();
  LatLng _currentLocation = const LatLng(23.6850, 90.3563);
  final LatLng _start = LatLng(23.7808875, 90.2792371); // Location A (Dhaka)
  final LatLng _destination = LatLng(23.810331, 90.412521); // Location B (Gulshan, Dhaka)
  Set<Polyline> _polylines = {}; // To store all polylines (route)
  List<LatLng> routeCords = []; // Route coordinates from Directions API

  @override
  void initState() {
    super.initState();
    // _getUserLocation(); // Get user location on map load
    _getRoute(); // Get the shortest route between _start and _destination
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    location.changeSettings(accuracy: LocationAccuracy.high);

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if the app has location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the user's current location
    locationData = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    // Move the camera to the user's location
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getRoute() async {
    // Get the route coordinates from Google Maps Directions API
    routeCords = await GoogleMapsService().getRouteCoordinates(_start, _destination);

    // Draw the polyline (route) on the map
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routeCords,
          width: 5,
          color: Colors.blue,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Example'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 10.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: _polylines, // Use the fetched polyline (shortest route)
        markers: {
          Marker(
            markerId: MarkerId('start'),
            position: _start,
            infoWindow: const InfoWindow(title: "Start Point"),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: _destination,
            infoWindow: const InfoWindow(title: "End Point"),
          ),
        },
      ),
    );
  }
}
