import 'dart:convert';
import 'dart:developer';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapExample extends StatefulWidget {
  const GoogleMapExample({super.key});

  @override
  State<GoogleMapExample> createState() => _GoogleMapExampleState();
}

class _GoogleMapExampleState extends State<GoogleMapExample> {
  LatLng _currentLocation = LatLng(23.765799551571796, 90.42222984586351);
  BitmapDescriptor customMarker = BitmapDescriptor.defaultMarker;
  Location location = Location();
  late GoogleMapController mapController;
  final customInfoWindowController = CustomInfoWindowController();
  final apiKey = "AIzaSyDAGsVp0FWyZdYBoB_TG54QyTZwPjet7-M";

  void getCustomMarker() {
    BitmapDescriptor.asset(ImageConfiguration(), "assets/image/marker.png")
        .then((icon) {
      if (mounted) {
        setState(() {
          customMarker = icon;
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    customInfoWindowController.googleMapController = controller;
  }

  final List<LatLng> _onPoint = [
    const LatLng(23.767292036287, 90.42274482997416),
    const LatLng(23.746194921049998, 90.41236028458717),
    const LatLng(23.74863923967637, 90.40356002266334),
    const LatLng(23.759082629119717, 90.38762851431197),
  ];

  final List<String> areNames = [
    "Rampura",
    "Malibagh",
    "Moghbazar",
    "Farmgate",
  ];
  final List<String> img =[
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiBf3tsfAUAE82e06gLLjf6uN66CBgXpD4zw&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUiCYk35ngATihLl9h10poVgfHFQAVkzjODA&s',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Moghbazar_Wireless_Square_in_a_holiday_morning._Dhaka._%282019%29.jpg/640px-Moghbazar_Wireless_Square_in_a_holiday_morning._Dhaka._%282019%29.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/3/39/Farmgate_metro_station.jpg',
    ];
  final Set<Marker> _marker = {};
  final Set<Polyline> _polyline = {};

  String _getStreetViewImageUrl(double latitude, double longitude) {
    return 'https://maps.googleapis.com/maps/api/streetview?size=600x300&location=$latitude,$longitude&key=$apiKey';
  } // get image url

  void onMapTapped(LatLng position){
    if(mounted){
      setState(() {
        _marker.clear();
        _marker.add(Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {
              customInfoWindowController.addInfoWindow!(
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Image.network(_getStreetViewImageUrl(position.latitude, position.longitude),height:125,width:250,fit:BoxFit.cover),
                        Text("Area Address")
                      ],
                    ),
                  ),
                  position
              );
            }));
      });
    }
  } // to see marker when user click on map anywhere

  void setPolyline() {
    // initialized marker set by forEach
    _onPoint.asMap().forEach((index, onPoint) {
      log(onPoint.toString());

      _marker.add(Marker(
          markerId: MarkerId(index.toString()),
          position: onPoint,
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            customInfoWindowController.addInfoWindow!(
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Image.network(img[index],height:125,width:250,fit:BoxFit.cover),
                  Text(areNames[index])
                ],
              ),
            ), onPoint);
          }));
    });

    setState(() {
      _polyline.add(Polyline(
          polylineId: PolylineId("Id"),
          points: _onPoint,
          color: Colors.blueAccent));
    });
  } // to see polyline

  Future<void> _userCurrentLocation() async {
    bool serviceEnable;
    PermissionStatus permissionStatus;
    LocationData locationData;

    serviceEnable = await location.serviceEnabled();
    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    }

    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 15)));
  } // to see uer-current location

  @override
  void initState() {
    // TODO: implement initState
    getCustomMarker();
    // _userCurrentLocation(); // uncomment the method to see current location
    // setPolyline(); //  uncomment the method to see polyline
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Google Map')),
        body: Stack(
          children: [
            GoogleMap(
              polylines: _polyline,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _currentLocation, zoom: 14),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: _marker,
              onTap: onMapTapped,
            ),
            CustomInfoWindow(
                controller: customInfoWindowController,
                height: 155,
                width: 250,
                offset: 40)
          ],
        ));
  }
}
