import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _mapboxToken =
      'pk.eyJ1IjoicXVhbmdnMTIiLCJhIjoiY21xODNxdGNuMDVxdTJycHFhaWh5b3MzayJ9.WmJKle4YZva6lQBPEZaJvw';
  static const _shopLocation = LatLng(10.84118, 106.80986);
  static const _shopAddress =
      'Lô E2a-7, Đường D1, Khu Công nghệ cao, phường Long Thạnh Mỹ, TP. Thủ Đức.';

  final fullName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final Distance _distance = const Distance();
  String selectedPayment = 'cod';
  String deliveryMode = 'manual';
  LatLng? deliveryLocation;
  int? shippingFee;
  double? deliveryDistanceKm;
  bool calculatingShipping = false;
  String? shippingMessage;

  @override
  void dispose() {
    fullName.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final subtotal = state.cartItems.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final activeShippingFee = shippingFee ?? 0;
    const discount = 0;
    final total = subtotal + activeShippingFee - discount;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: const Text('SPORTZONE'),
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 1.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ĐƠN HÀNG CỦA BẠN',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: state.cartItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: ProductImage(
                              imageUrl: item.imageUrl,
                              productName: item.name,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.toUpperCase(),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Size: ${item.size} • Màu: ${item.color} • x${item.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: SportZoneTheme.secondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatVnd(item.price),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: SportZoneTheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'THÔNG TIN GIAO HÀNG',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullName,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: address,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng (Số nhà, Phố, Quận, TP)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _deliveryModeButton(
                      context,
                      label: 'Tự nhập',
                      icon: Icons.edit_location_alt,
                      selected: deliveryMode == 'manual',
                      onTap: () => setState(() => deliveryMode = 'manual'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _deliveryModeButton(
                      context,
                      label: 'Chọn trên map',
                      icon: Icons.map_outlined,
                      selected: deliveryMode == 'map',
                      onTap: _pickAddressOnMap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SportZoneTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront,
                          color: SportZoneTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Shop: $_shopAddress',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (deliveryDistanceKm != null)
                      Text(
                        'Khoảng cách ước tính: ${deliveryDistanceKm!.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                    if (shippingMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        shippingMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SportZoneTheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: calculatingShipping
                            ? null
                            : _calculateShippingFromCurrentInput,
                        icon: calculatingShipping
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.local_shipping_outlined),
                        label: Text(
                          calculatingShipping
                              ? 'Đang tính phí ship...'
                              : 'Tính phí vận chuyển',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PHƯƠNG THỨC THANH TOÁN',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...[
                PaymentOption(
                  code: 'cod',
                  label: 'Thanh toán khi nhận hàng (COD)',
                  icon: Icons.local_shipping,
                ),
                PaymentOption(
                  code: 'bank_transfer',
                  label: 'Chuyển khoản ngân hàng',
                  icon: Icons.account_balance,
                ),
                PaymentOption(
                  code: 'e_wallet',
                  label: 'Ví điện tử (Momo/ZaloPay)',
                  icon: Icons.account_balance_wallet,
                ),
                PaymentOption(
                  code: 'stripe',
                  label: 'Thẻ quốc tế (Stripe)',
                  icon: Icons.credit_card,
                ),
              ].map((payment) {
                final selected = selectedPayment == payment.code;
                return GestureDetector(
                  onTap: () => setState(() => selectedPayment = payment.code),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? SportZoneTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(payment.icon, color: SportZoneTheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              payment.label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: SportZoneTheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              _priceRow(context, 'Tạm tính:', subtotal),
              const SizedBox(height: 8),
              _priceRow(context, 'Phí vận chuyển:', activeShippingFee),
              const SizedBox(height: 8),
              _priceRow(context, 'Coupon:', -discount, negative: true),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: SportZoneTheme.surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TỔNG CỘNG',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SportZoneTheme.secondary,
                  ),
                ),
                Text(
                  formatVnd(state.cartItems.isEmpty ? 0 : total),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportZoneTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: state.cartItems.isEmpty
                    ? null
                    : () async {
                        final name = fullName.text.trim();
                        final phoneStr = phone.text.trim();
                        final addr = address.text.trim();

                        if (name.isEmpty || phoneStr.isEmpty || addr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng nhập đủ họ tên, số điện thoại và địa chỉ.',
                              ),
                            ),
                          );
                          return;
                        }

                        final calculated = await _ensureShippingCalculated();
                        if (!context.mounted) return;
                        if (!calculated) return;

                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        final result = await state.checkout(
                          recipientName: name,
                          phone: phoneStr,
                          street: addr,
                          paymentMethod: selectedPayment,
                          shippingFee: shippingFee,
                        );

                        if (!mounted) return;
                        navigator.pop(); // Pop loading dialog

                        if (result.isSuccess) {
                          if (selectedPayment == 'stripe') {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đang chuyển hướng sang Stripe...',
                                ),
                              ),
                            );
                            final orderId = result.data['orderId'];
                            if (orderId != null) {
                              final stripeResult =
                                  await ApiService.createStripeCheckoutSession(
                                    orderId,
                                  );
                              if (stripeResult.isSuccess &&
                                  stripeResult.data['checkoutUrl'] != null) {
                                final url = Uri.parse(
                                  stripeResult.data['checkoutUrl'],
                                );
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } else {
                                if (!context.mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      stripeResult.errorMessage ??
                                          'Không thể mở trang thanh toán Stripe',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Đặt hàng thành công!'),
                              ),
                            );
                          }

                          navigator.pushNamedAndRemoveUntil(
                            '/main',
                            (route) => route.isFirst,
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                result.errorMessage ?? 'Đặt hàng thất bại',
                              ),
                            ),
                          );
                        }
                      },
                child: Text(
                  'ĐẶT HÀNG',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SportZoneTheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryModeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? SportZoneTheme.primary : SportZoneTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SportZoneTheme.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? SportZoneTheme.onPrimary
                  : SportZoneTheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? SportZoneTheme.onPrimary
                      : SportZoneTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAddressOnMap() async {
    final result = await Navigator.push<_MapAddressResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _CheckoutMapPickerScreen(
          initialPoint: deliveryLocation ?? _shopLocation,
          mapboxToken: _mapboxToken,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      deliveryMode = 'map';
      deliveryLocation = result.location;
      address.text = result.address;
      _setShippingFromLocation(result.location);
      shippingMessage =
          'Đã chọn pin trên map. Phí ship tính theo khoảng cách từ shop tới điểm giao.';
    });
  }

  Future<void> _calculateShippingFromCurrentInput() async {
    if (deliveryMode == 'map' && deliveryLocation != null) {
      setState(() {
        _setShippingFromLocation(deliveryLocation!);
        shippingMessage =
            'Phí ship tính theo pin giao hàng bạn đã chọn trên map.';
      });
      return;
    }

    if (address.text.trim().isEmpty) {
      setState(() => shippingMessage = 'Vui lòng nhập địa chỉ giao hàng.');
      return;
    }

    setState(() {
      calculatingShipping = true;
      shippingMessage = null;
    });
    try {
      final location = await _geocodeAddress(address.text.trim());
      if (location == null) {
        setState(() {
          shippingMessage =
              'Không tìm được tọa độ địa chỉ. Bạn có thể chọn vị trí bằng map.';
        });
        return;
      }
      setState(() {
        deliveryLocation = location;
        _setShippingFromLocation(location);
        shippingMessage =
            'Đã tính phí ship từ địa chỉ nhập tay. Bạn có thể chọn map để chính xác hơn.';
      });
    } finally {
      if (mounted) setState(() => calculatingShipping = false);
    }
  }

  Future<bool> _ensureShippingCalculated() async {
    if (shippingFee != null) return true;
    await _calculateShippingFromCurrentInput();
    if (!mounted) return false;
    if (shippingFee != null) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng tính phí vận chuyển trước khi đặt hàng.'),
      ),
    );
    return false;
  }

  Future<LatLng?> _geocodeAddress(String value) async {
    final query =
        value.toLowerCase().contains('hồ chí minh') ||
            value.toLowerCase().contains('tp.hcm') ||
            value.toLowerCase().contains('hcm')
        ? value
        : '$value, TP. Hồ Chí Minh, Việt Nam';
    final uri = Uri.parse('https://api.mapbox.com/search/geocode/v6/forward')
        .replace(
          queryParameters: {
            'q': query,
            'country': 'vn',
            'limit': '1',
            'language': 'vi',
            'access_token': _mapboxToken,
          },
        );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (response.statusCode != 200 || features.isEmpty) return null;
      final feature = features.first as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      return LatLng(
        (coordinates[1] as num).toDouble(),
        (coordinates[0] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  void _setShippingFromLocation(LatLng location) {
    final meters = _distance.as(LengthUnit.Meter, _shopLocation, location);
    final km = meters / 1000;
    deliveryDistanceKm = km;
    shippingFee = _shippingFeeForDistance(km);
  }

  int _shippingFeeForDistance(double km) {
    const baseFee = 18000;
    const extraPerKm = 5000;
    const minFee = 15000;
    const maxFee = 40000;
    final extraKm = km <= 2 ? 0 : (km - 2).ceil();
    final fee = baseFee + extraKm * extraPerKm;
    return fee.clamp(minFee, maxFee);
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    int amount, {
    bool negative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
        ),
        Text(
          '${negative ? '- ' : ''}${formatVnd(amount.abs())}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: negative ? SportZoneTheme.error : SportZoneTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _MapAddressResult {
  final LatLng location;
  final String address;

  const _MapAddressResult({required this.location, required this.address});
}

class _CheckoutMapPickerScreen extends StatefulWidget {
  final LatLng initialPoint;
  final String mapboxToken;

  const _CheckoutMapPickerScreen({
    required this.initialPoint,
    required this.mapboxToken,
  });

  @override
  State<_CheckoutMapPickerScreen> createState() =>
      _CheckoutMapPickerScreenState();
}

class _CheckoutMapPickerScreenState extends State<_CheckoutMapPickerScreen> {
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
                    const Marker(
                      point: _CheckoutScreenState._shopLocation,
                      width: 52,
                      height: 52,
                      child: _CheckoutMapPin(
                        icon: Icons.storefront,
                        color: SportZoneTheme.electricLime,
                      ),
                    ),
                    Marker(
                      point: _selectedPoint,
                      width: 52,
                      height: 52,
                      child: const _CheckoutMapPin(
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
                      _MapAddressResult(
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

class _CheckoutMapPin extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CheckoutMapPin({required this.icon, required this.color});

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

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
