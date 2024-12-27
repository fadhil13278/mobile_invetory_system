import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/supplier_model.dart';
import '../utils/database_helper.dart';
import 'select_location_screen.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({super.key, required this.supplier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _addressController = TextEditingController(text: widget.supplier.address);
    _phoneController = TextEditingController(text: widget.supplier.phone);

    if (widget.supplier.latitude != null && widget.supplier.longitude != null) {
      _selectedLocation = LatLng(
        widget.supplier.latitude!,
        widget.supplier.longitude!,
      );
    }
  }

  Future<void> _openLocationPicker() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen(
          onLocationSelected: (LatLng location) {
            setState(() {
              _selectedLocation = location;
            });
          },
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedSupplier = Supplier(
          id: widget.supplier.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        );

        await DatabaseHelper().updateSupplier(updatedSupplier);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil diperbarui')),
        );

        if (mounted) {
          Navigator.pop(context, updatedSupplier);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating supplier: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supplier'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.trim().isEmpty == true ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value?.trim().isEmpty == true ? 'Telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.trim().isEmpty == true ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Lokasi Pemasok:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedLocation == null ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _openLocationPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.location_on),
                label: Text(_selectedLocation == null
                    ? 'Pilih Lokasi Pemasok'
                    : 'Ubah Lokasi Pemasok'),
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi terpilih:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                          ),
                          Text(
                            'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
