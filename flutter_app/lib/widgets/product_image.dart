import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_app/api_service.dart';
import 'package:flutter_app/theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final BoxFit fit;

  const ProductImage({
    required this.imageUrl,
    required this.productName,
    this.fit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty || cleanUrl.contains('example.com')) {
      if (cleanUrl.contains('nike-tshirt')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('adidas-short')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('puma-tshirt')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('ua-pants')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('nike-jacket')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=600&q=80';
      } else {
        return _placeholder(context);
      }
    }

    if (cleanUrl.startsWith('/')) {
      final host = ApiService.baseUrl.replaceAll('/api/v1', '');
      cleanUrl = host + cleanUrl;
    }

    if (kIsWeb && cleanUrl.startsWith('http')) {
      cleanUrl =
          '${ApiService.baseUrl}/products/image-proxy?url=${Uri.encodeComponent(cleanUrl)}';
    }

    return Image.network(
      cleanUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: SportZoneTheme.primary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: SportZoneTheme.surfaceVariant,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: SportZoneTheme.secondary,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width:
                  100, // Constrain width so text can wrap if needed, then scale down
              child: Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SportZoneTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
