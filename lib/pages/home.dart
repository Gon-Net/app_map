import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  MapController _mapController = MapController();

  var lat = -16.495991;
  var lng = -68.134120;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();    
    permission();
    miubicacion();
  }

  permission() async{
    var status = await Permission.location.status;
    if(!status.isGranted){
      await Permission.location.request();
    }
  }

  miubicacion() async{
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      lng = position.longitude;
    });
    _mapController.move(LatLng(lat,lng), 13);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Hello Home 1234'),        
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(lat, lng), // Center the map over London
          initialZoom: 13,
        ),
        children: [
          TileLayer( // Display map tiles from any source
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
            userAgentPackageName: 'com.example.app',
            // And many more recommended properties!
          ),

          MarkerLayer(
            markers:  [
              Marker(
                point: LatLng(lat, lng),
                width: 35,
                height:35,
                child: Icon(Icons.location_on, color: Colors.red,),
              ),
            ],
          ),

          RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
              ),
              // Also add images...
            ],
          ),
        ],
      ),
    );
  }
}
