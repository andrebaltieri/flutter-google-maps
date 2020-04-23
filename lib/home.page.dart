import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController mapController;
  double zoom = 11;
  Set<Marker> markers = new Set<Marker>();
  String url =
      "https://maps.googleapis.com/maps/api/geocode/json?key=SUA-CHAVE-AQUI&address=";

  LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future searchAdress(address) async {
    Response response = await Dio().get(url + address);

    String city =
        response.data["results"][0]["address_components"][3]["long_name"];
    String formattedAddress = response.data["results"][0]["formatted_address"];
    _center = LatLng(
      response.data["results"][0]["geometry"]["location"]["lat"],
      response.data["results"][0]["geometry"]["location"]["lng"],
    );

    setMapPosition(city, formattedAddress);
  }

  setMapPosition(title, snippet) {
    mapController.animateCamera(CameraUpdate.newLatLng(_center));
    markers = Set<Marker>();

    Marker marker = Marker(
      markerId: MarkerId("1"),
      position: _center,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
    markers.add(marker);
    zoom = 18;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoTextField(
          placeholder: "Pesquisar endereço",
          onSubmitted: (val) {
            searchAdress(val);
          },
        ),
        trailing: CupertinoButton(
          child: Icon(CupertinoIcons.location),
          onPressed: () async {
            Position position = await Geolocator().getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            _center = LatLng(
              position.latitude,
              position.longitude,
            );
            setMapPosition("Apple", "Posição Atual");
          },
        ),
      ),
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: zoom,
        ),
        markers: markers,
      ),
    );
  }
}
