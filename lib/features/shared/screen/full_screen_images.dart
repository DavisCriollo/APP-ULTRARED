import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/domain/entities/imagen.dart';

class FullScreenImagesPage extends StatefulWidget {
  final List<Imagen> images;
  final int initialIndex;

  const FullScreenImagesPage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImagesPage> createState() => _FullScreenImagesPageState();
}

class _FullScreenImagesPageState extends State<FullScreenImagesPage> {
  late PageController _pageController;
  bool _pageViewScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Listener(
        onPointerSignal: (_) {}, // evita warnings en web
        child: PageView.builder(
          controller: _pageController,
          physics: _pageViewScrollEnabled
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: widget.images.length,
          itemBuilder: (_, index) {
            final image = widget.images[index];
            final imageProvider = image.url.startsWith('http')
                ? NetworkImage(image.url)
                : FileImage(File(image.url)) as ImageProvider;

            return Center(
              child: _ZoomableImage(
                imageProvider: imageProvider,
                onZoomChanged: (isZoomed) {
                  setState(() {
                    _pageViewScrollEnabled = !isZoomed;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final void Function(bool isZoomed) onZoomChanged;

  const _ZoomableImage({
    required this.imageProvider,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.0);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransform);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      panEnabled: true,
      scaleEnabled: true,
      minScale: 1.0,
      maxScale: 4.0,
      child: Image(image: widget.imageProvider),
    );
  }
}
