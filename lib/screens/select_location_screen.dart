import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const SelectLocationScreen({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selectedLocation;
// ignore: unused_field
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _onConfirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(_selectedLocation!);
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih lokasi pada peta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.initialLocation ?? const LatLng(-6.200000, 106.816666);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTapped,
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12.0,
            ),
            markers: _selectedLocation != null
                ? {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation!,
              ),
            }
                : {},
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            padding: const EdgeInsets.only(bottom: 100),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _onConfirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Konfirmasi Lokasi'),
            ),
          ),
        ],
      ),
    );
  }
}
