import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/supplier_model.dart';
import '../utils/database_helper.dart';
import 'edit_supplier_screen.dart';

class DetailSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const DetailSupplierScreen({super.key, required this.supplier});

  @override
  State<DetailSupplierScreen> createState() => _DetailSupplierScreenState();
}

class _DetailSupplierScreenState extends State<DetailSupplierScreen> {
  late Supplier _supplier;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _supplier = widget.supplier;
  }

  Future<void> _deleteSupplier() async {
    try {
      await DatabaseHelper().deleteSupplier(_supplier.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier berhasil dihapus')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting supplier: $e')),
      );
    }
  }

  Future<void> _editSupplier() async {
    final updatedSupplier = await Navigator.of(context).push<Supplier>(
      MaterialPageRoute(
        builder: (context) => EditSupplierScreen(supplier: _supplier),
      ),
    );

    if (updatedSupplier != null) {
      if (mounted) {
        setState(() {
          _supplier = updatedSupplier;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Supplier'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editSupplier,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSupplier,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _supplier.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _supplier.phone,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _supplier.address,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.map, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Latitude: ${_supplier.latitude?.toStringAsFixed(6) ?? "N/A"}, Longitude: ${_supplier.longitude?.toStringAsFixed(6) ?? "N/A"}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _supplier.latitude != null && _supplier.longitude != null
                  ? SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_supplier.latitude!, _supplier.longitude!),
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(_supplier.id.toString()),
                      position: LatLng(_supplier.latitude!, _supplier.longitude!),
                      infoWindow: InfoWindow(title: _supplier.name),
                    ),
                  },
                ),
              )
                  : const Text('Koordinat tidak tersedia untuk supplier ini.'),
            ],
          ),
        ),
      ),
    );
  }
}
