import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapapi/DiractionRepositry.dart';
import 'package:mapapi/Directions.dart';
import 'package:provider/provider.dart';

import 'Provider/Loaction_Provider.dart';

class Map_Screen extends StatefulWidget {
  const Map_Screen({super.key});

  @override
  State<Map_Screen> createState() => _Map_ScreenState();
}

class _Map_ScreenState extends State<Map_Screen> {


  // static const _initialCameraPosition = CameraPosition(target: LatLng(28.618168,77.377317),zoom: 11.5);

  late GoogleMapController  _googleMapController;


   Marker? _orgmarker;
   Marker? _destination;
   Directions? _info;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<LocationProvider>().getLocation());
  }


  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    // final location = Provider.of<LocationProvider>(context)..getLocation();

    // if still loading, show spinner
    if (location.isLookingForLocation || location.userLat == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(location.userLat!, location.userLong!),
      infoWindow: const InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    final CameraPosition _initialCameraPosition = CameraPosition(
      target: LatLng(location.userLat!, location.userLong!),
      zoom: 14,
    );


    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Google Maps"),
        actions: [
          TextButton(
              onPressed: () => _googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _orgmarker!.position,zoom: 14.5,tilt: 50.0)
            )
          ), child: Text("ORIGIN")),
          if(_destination != null)
          TextButton(
              onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(target: _destination!.position,zoom: 14.5,tilt: 50.0)
                  )
              ), child: Text("Destin"))
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            // myLocationEnabled: true,
            compassEnabled: true,
            myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              currentMarker,
              if(_orgmarker != null) _orgmarker!,
              if(_destination != null) _destination!
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId("overview_polyline"),
                  color: Colors.indigoAccent,
                  width: 5,
                  points: _info!.polylinePoints,
                ),

            },
            onLongPress: _addMarker,
          ),
          if(_info != null )
            Positioned(
                bottom: 50,
                child: Container(
              padding: EdgeInsets.symmetric( vertical: 6 ,horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0
                  )
                ]

              ),
              child: Text(
                "${_info!.totalDistance}, ${_info!.totalDuration}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18
                ),
              ),
            )),



        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        child: Icon(Icons.center_focus_strong),
        onPressed: () => _googleMapController.animateCamera(
          _info != null ?
            CameraUpdate.newLatLngBounds(_info!.bounds,100.0) :
            CameraUpdate.newCameraPosition(_initialCameraPosition)
        ),),
    );
  }

  void _addMarker(LatLng pos) async{
    if(_orgmarker == null || (_orgmarker != null && _destination != null)){
      /// Origin is not Set Or Org
      setState(() {
        _orgmarker =Marker(markerId: const MarkerId('origin'),
        infoWindow: InfoWindow(title: "Origin"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos
        );
        _destination = null;

        _info = null;
      });
    }else {
      /// Origin is  already set
      setState(() {
        _destination =Marker(markerId: const MarkerId('destination'),
            infoWindow: InfoWindow(title: "Destination"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos
        );
      });

      final diraction = await DiractionRepositry().getDiractions(origin: _orgmarker!.position, destination: pos);
      setState(() {
        _info = diraction;
      });
    }
  }

}
