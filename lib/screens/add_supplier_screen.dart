import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/supplier_model.dart';
import '../utils/database_helper.dart';
import 'select_location_screen.dart';

class AddSupplierScreen extends StatefulWidget {
  final Function() onSupplierAdded;

  const AddSupplierScreen({super.key, required this.onSupplierAdded});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  LatLng? _selectedLocation;

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
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi dipilih: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})',
          ),
        ),
      );
    }
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      try {
        final supplier = Supplier(
          name: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        );

        await DatabaseHelper().insertSupplier(supplier);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier berhasil ditambahkan!')),
        );

        widget.onSupplierAdded();
        Navigator.pop(context);
      } catch (e) {
        // Tampilkan pesan error yang lebih informatif
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan supplier: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Supplier'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Supplier'),
                validator: (value) =>
                value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) =>
                value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openLocationPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Pilih Lokasi Pemasok'),
              ),
              const SizedBox(height: 16),
              if (_selectedLocation != null)
                Text(
                  'Lokasi dipilih: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})',
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Simpan Supplier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
