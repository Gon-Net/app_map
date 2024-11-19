import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_map/pages/page2.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app_map/services/location_service.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  MapController _mapController = MapController();

  var lat = -17.013472;
  var lng = -64.192689;
  //List<Map<String, dynamic>> locations = [];
  List locations = [];
  List<LatLng> polylinePoints = [];

  @override
  void initState() {
    super.initState();    
    permission();
    //miubicacion();
    getLocations();
  }

  getLocations() async {
    var locations = await LocationService().getLocations();
    print(locations);
    setState(() {
      this.locations = locations;
    });
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
    _mapController.move(LatLng(lat,lng), 17);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),        
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Mi ubicación'),
              onTap: () {
                miubicacion();
              },
            ),
            ListTile(
              title: const Text('Pagina 2'),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Page2())
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: locations.length,
            itemBuilder: (context, index){ 
              return ElevatedButton(
                onPressed: () async {

                  var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                  print('position >>> ${position}');
                  //String url = 'https://router.project-osrm.org/route/v1/driving/${position.longitude},${position.latitude};${locations[index]['longitude']},${locations[index]['latitude']}?geometries=geojson';
                  
                  print('longitud origen >>> ${lng}');
                  print('latitud origen >>> ${lat}');
                  print('longitud destino >>> ${locations[index]['longitude']}');
                  print('latitud destino >>> ${locations[index]['latitude']}');

                  if (position.longitude != null && position.latitude != null && locations[index]['longitude'] != null && locations[index]['latitude'] != null) {
                    //String url = 'https://router.project-osrm.org/route/v1/driving/${position.longitude},${position.latitude};${locations[index]['longitude']},${locations[index]['latitude']}?geometries=geojson';
                    String url = 'https://router.project-osrm.org/route/v1/driving/${lng},${lat};${locations[index]['longitude'].toString()},${locations[index]['latitude'].toString()}?geometries=geojson';
                    final response = await http.get(Uri.parse(url));
                    print('Estado response >>> ${response.statusCode}');
                    if(response.statusCode == 200){
                      final data = json.decode(response.body);
                      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

                      setState(() {
                      polylinePoints = coordinates
                        .map((point) => LatLng(point[1], point[0]))
                        .toList();
                      });

                    } else {
                      print('Error al obtener la ruta: ${response.statusCode}');
                    }

                  } else {
                    print('Error: Alguna coordenada es nula');
                  }

                  setState(() {
                     lat = double.parse(locations[index]['latitude']);
                     lng = double.parse(locations[index]['longitude']);
                   });
                   _mapController.move(LatLng(lat, lng), 6);
                }, 
                child: Text(locations[index]['name']),
              );
            },
          ),

          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(lat, lng), // Center the map over London
                initialZoom: 5.6,
              ),
              children: [
                TileLayer( // Display map tiles from any source
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  // And many more recommended properties!
                ),

                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    )
                  ]
                ),
            
                MarkerLayer(
                  markers:  [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 70,
                      height: 70,
                      child: GestureDetector(
                        child: Icon(Icons.location_on, color: Colors.red),
                        onTap: () {
                          print('Ubicacion actual');
                        }),
                    ),
                  ],
                ),
            
                RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                       onTap: () => print('OpenStreetMap contributors'),                        // (external)
                    ),
                    // Also add images...
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
