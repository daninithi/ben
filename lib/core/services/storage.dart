import 'dart:io';
import 'package:dio/dio.dart';

class StorageService {
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dkvh1lius/image/upload';
  final String uploadPreset ='chatapp';

  Future<String?> uploadImage(File imageFile) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      'upload_preset': uploadPreset,
    });

 try {
    final response = await dio.post(cloudinaryUrl, data: formData);
    print(response.data); // Print Cloudinary's response
    if (response.statusCode == 200) {
      return response.data['secure_url'];
    }
    return null;
  } on DioException catch (e) {
    print(e.response?.data); // Print error details from Cloudinary
    return null;
  }
  }
}