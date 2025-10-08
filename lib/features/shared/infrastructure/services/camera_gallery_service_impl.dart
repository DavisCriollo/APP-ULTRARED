import 'package:ultrared/features/shared/infrastructure/services/camera_gallery_service.dart';
import 'package:image_picker/image_picker.dart';

class CameraGalleryServiceImpl extends CameraGalleryService {
  final ImagePicker _picker = ImagePicker();
  @override
  Future<String?> selectPhoto() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear);
    if (photo == null) return null;

    return photo.path;
  }

  Future<List<String>> selectPhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage(imageQuality: 80);
    if (photos.isEmpty) return [];
    return photos.map((p) => p.path).toList();
  }

  @override
  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear);
    if (photo == null) return null;

    return photo.path;
  }
}
