import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _initialPosition;
  LatLng? _currentCenterPosition;
  bool _isLoadingLocation = true;
  String _address = 'Dragging...';
  String _region = '';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _currentCenterPosition = _initialPosition;
          _isLoadingLocation = false;
        });
        _updateAddress(_currentCenterPosition!);
      } else {
        setState(() {
          _initialPosition = const LatLng(28.6139, 77.2090);
          _currentCenterPosition = _initialPosition;
          _isLoadingLocation = false;
        });
        _updateAddress(_currentCenterPosition!);
      }
    } catch (e) {
      setState(() {
        _initialPosition = const LatLng(28.6139, 77.2090);
        _currentCenterPosition = _initialPosition;
        _isLoadingLocation = false;
      });
      _updateAddress(_currentCenterPosition!);
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() {
      _address = 'Fetching address...';
      _region = '';
    });
    try {
      final geocoder = Geocoding();
      List<Placemark> placemarks = await geocoder.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final sub = place.subAdministrativeArea ?? place.locality ?? '';
        final state = place.administrativeArea ?? '';
        final region = [sub, state].where((s) => s.isNotEmpty).join(', ');
        
        setState(() {
          _address = place.locality ?? sub;
          if (_address.isEmpty) _address = 'Unknown location';
          _region = region;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Address not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Location',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 15.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (CameraPosition position) {
                    _currentCenterPosition = position.target;
                    setState(() {
                      _address = 'Dragging...';
                      _region = '';
                    });
                  },
                  onCameraIdle: () {
                    if (_currentCenterPosition != null) {
                      _updateAddress(_currentCenterPosition!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // Center Pin Icon
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Icon(
                      Icons.location_pin,
                      size: 50.0,
                      color: Colors.red,
                    ),
                  ),
                ),
                // Confirm Button Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selected Location',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _address,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_region.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _region,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _address == 'Dragging...' || _address == 'Fetching address...'
                              ? null
                              : () {
                                  Navigator.pop(context, {
                                    'city': _address,
                                    'region': _region,
                                    'latLng': _currentCenterPosition,
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Confirm Location',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Custom My Location Button
                Positioned(
                  bottom: 220,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "my_location_fab",
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    onPressed: () async {
                      if (_initialPosition != null && _mapController != null) {
                        final position = await Geolocator.getCurrentPosition();
                        final latLng = LatLng(position.latitude, position.longitude);
                        _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
                      }
                    },
                    child: Icon(Icons.my_location, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
    );
  }
}
