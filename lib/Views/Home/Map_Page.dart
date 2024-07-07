import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_application_1/Views/Home/Const.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _kGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _kApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentPosition;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await getLocationUpdate();
      List<LatLng> polylineCoordinates = await getPolylinePoints();
      generatePolylineFromPoints(polylineCoordinates);
    } catch (e) {
      print('Error initializing map: $e');
      // Handle error as needed, e.g., show a snackbar, retry logic, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition:
                  CameraPosition(target: _kGooglePlex, zoom: 14),
              markers: {
                Marker(
                  markerId: MarkerId('Current Location'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentPosition!,
                ),
                Marker(
                  markerId: MarkerId('Google Plex'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _kGooglePlex,
                ),
                Marker(
                  markerId: MarkerId('Apple Park'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _kApplePark,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> getLocationUpdate() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        throw 'Location services are disabled.';
      }
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw 'Location permission denied.';
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentPosition!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: GOOGLE_MAPS_API_KEY,
        request: PolylineRequest(
            origin: PointLatLng(_kGooglePlex.latitude, _kGooglePlex.longitude),
            destination:
                PointLatLng(_kApplePark.latitude, _kApplePark.longitude),
            mode: TravelMode.driving));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      throw 'No polyline points found.';
    }
    return polylineCoordinates;
  }

  Future<void> _cameraToPosition(LatLng latLng) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition =
        CameraPosition(target: latLng, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}
