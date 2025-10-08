import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/domain/entities/imagen.dart';
import 'package:ultrared/features/shared/infrastructure/services/camera_gallery_service_impl.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class ImageGallery extends StatelessWidget {
  final List<Imagen> images;
  final Responsive size;

  /// Callback para solicitar agregar una imagen.
  /// Debe devolver la URL/path de la imagen añadida o null si se canceló.
  final Future<void> Function(List<Imagen> urls) onAdd;

  /// Callback cuando se solicita eliminar una imagen.
  /// Recibe la URL/path de la imagen a eliminar.
  final void Function(String url, bool isUploaded) onDelete;

  const ImageGallery({
    super.key,
    required this.images,
    required this.size,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.hScreen(25),
      child: images.isEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: FloatingActionButton.small(
                      heroTag: const ValueKey('image_gallery_add_empty'),
                      onPressed: () async {
                        final photPath =
                            await CameraGalleryServiceImpl().selectPhotos();

                        await onAdd(photPath
                            .map((e) => Imagen(
                                nombre: 'imagen${images.length + 1}', url: e))
                            .toList());
                        // El manejo del resultado (actualizar lista) lo hace el caller.
                      },
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
            )
          : PageView(
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 0.7),
              children: images.map((image) {
                late ImageProvider imageProvider;
                if (image.url.startsWith('http')) {
                  imageProvider = NetworkImage(image.url);
                } else {
                  imageProvider = FileImage(File(image.url));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FadeInImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                          placeholder: const AssetImage(
                              'assets/loaders/bottle-loader.gif'),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.white),
                              onPressed: () {
                                onDelete(
                                    image.url, image.url.startsWith('http'));
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: FloatingActionButton.small(
                            heroTag: ValueKey('image_gallery_add_${image.url}'),
                            onPressed: () async {
                              final photPath = await CameraGalleryServiceImpl()
                                  .selectPhotos();

                              await onAdd(photPath
                                  .map((e) => Imagen(
                                      nombre: 'imagen${images.length + 1}',
                                      url: e))
                                  .toList());
                              // caller actualizará la lista si retorna url != null
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
