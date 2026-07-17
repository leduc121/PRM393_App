import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapAddressResult {
  final LatLng location;
  final String address;

  const MapAddressResult({required this.location, required this.address});
}

class CheckoutMapPickerScreen extends StatefulWidget {
  final LatLng initialPoint;
  final String mapboxToken;
  final LatLng shopLocation;

  const CheckoutMapPickerScreen({
    super.key,
    required this.initialPoint,
    required this.mapboxToken,
    required this.shopLocation,
  });

  @override
  State<CheckoutMapPickerScreen> createState() =>
      CheckoutMapPickerScreenState();
}

class CheckoutMapPickerScreenState extends State<CheckoutMapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _selectedPoint;
  bool _resolvingAddress = false;
  String _selectedAddress = 'Vị trí đã chọn trên bản đồ';

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
    unawaited(_reverseGeocode(_selectedPoint));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: const Text('Chọn điểm giao hàng'),
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 14.5,
                minZoom: 4,
                maxZoom: 19,
                onTap: (_, point) {
                  setState(() {
                    _selectedPoint = point;
                    _selectedAddress = 'Đang đọc địa chỉ...';
                  });
                  unawaited(_reverseGeocode(point));
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/512/{z}/{x}/{y}?access_token=${widget.mapboxToken}',
                  tileDimension: 512,
                  zoomOffset: -1,
                  maxNativeZoom: 22,
                  userAgentPackageName: 'com.example.flutter_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.shopLocation,
                      width: 52,
                      height: 52,
                      child: const CheckoutMapPin(
                        icon: Icons.storefront,
                        color: SportZoneTheme.electricLime,
                      ),
                    ),
                    Marker(
                      point: _selectedPoint,
                      width: 52,
                      height: 52,
                      child: const CheckoutMapPin(
                        icon: Icons.location_on,
                        color: Color(0xFF1D6CFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SportZoneTheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_resolvingAddress)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.touch_app, color: SportZoneTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chạm bản đồ để đặt pin giao hàng',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 160,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: SportZoneTheme.surface,
                  foregroundColor: SportZoneTheme.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: SportZoneTheme.surface,
                  foregroundColor: SportZoneTheme.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(color: SportZoneTheme.surface),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _selectedAddress,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SportZoneTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MapAddressResult(
                        location: _selectedPoint,
                        address: _selectedAddress,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('DÙNG VỊ TRÍ NÀY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SportZoneTheme.primary,
                    foregroundColor: SportZoneTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _resolvingAddress = true);
    final uri = Uri.parse('https://api.mapbox.com/search/geocode/v6/reverse')
        .replace(
          queryParameters: {
            'longitude': point.longitude.toString(),
            'latitude': point.latitude.toString(),
            'language': 'vi',
            'access_token': widget.mapboxToken,
          },
        );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      final address = features.isEmpty
          ? 'Vị trí đã chọn: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}'
          : ((features.first as Map<String, dynamic>)['properties']
                        as Map<String, dynamic>?)?['full_address']
                    ?.toString() ??
                'Vị trí đã chọn: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      if (!mounted) return;
      setState(() => _selectedAddress = address);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress =
            'Vị trí đã chọn: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      });
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }
}

class CheckoutMapPin extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CheckoutMapPin({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: SportZoneTheme.primary),
    );
  }
}
