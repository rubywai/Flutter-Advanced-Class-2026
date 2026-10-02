import 'package:flutter/material.dart';

import '../../data/models/product_detail.dart';

class ProductDetailGallery extends StatefulWidget {
  const ProductDetailGallery({
    super.key,
    required this.images,
    required this.productName,
  });
  final List<ProductDetailImage> images;
  final String productName;

  @override
  State<ProductDetailGallery> createState() => _ProductDetailGalleryState();
}

class _ProductDetailGalleryState extends State<ProductDetailGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProductDetailGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length != oldWidget.images.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: widget.images.isEmpty
            ? const _ImageUnavailable()
            : PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  return Image.network(
                    image.url,
                    fit: BoxFit.contain,
                    semanticLabel: image.alt.isEmpty
                        ? widget.productName
                        : image.alt,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImageUnavailable(),
                  );
                },
              ),
      ),
      if (widget.images.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous image',
                onPressed: _index == 0
                    ? null
                    : () => _controller.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                icon: const Icon(Icons.chevron_left),
              ),
              Flexible(
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: 'Next image',
                onPressed: _index == widget.images.length - 1
                    ? null
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
    ],
  );
}

class _ImageUnavailable extends StatelessWidget {
  const _ImageUnavailable();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        semanticLabel: 'Image unavailable',
      ),
    ),
  );
}
