import 'package:flutter/material.dart';
import 'models/property_model.dart';
import 'services/property_api_service.dart';
import 'property_details_screen.dart';

class PropertyDetailsLoader extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsLoader({super.key, required this.propertyId});

  @override
  State<PropertyDetailsLoader> createState() => _PropertyDetailsLoaderState();
}

class _PropertyDetailsLoaderState extends State<PropertyDetailsLoader> {
  bool _isLoading = true;
  String? _error;
  Property? _property;

  @override
  void initState() {
    super.initState();
    _fetchProperty();
  }

  Future<void> _fetchProperty() async {
    try {
      final property = await PropertyApiService.getPropertyById(widget.propertyId);
      if (mounted) {
        setState(() {
          _property = property;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Failed to load property.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchProperty();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PropertyDetailsScreen(property: _property!);
  }
}
