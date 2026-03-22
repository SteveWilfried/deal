import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/app_config.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════
//  UploadService — Upload photos vers Supabase Storage
// ═══════════════════════════════════════════════════════════

class UploadResult {
  final String url;
  final String path;

  const UploadResult({required this.url, required this.path});
}

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  /// Upload une image et retourne l'URL publique.
  /// [file] — fichier image sélectionné via image_picker
  Future<UploadResult?> uploadImage(File file) async {
    if (!AppConfig.useRealBackend) {
      debugPrint('UploadService: mode démo — retourne URL fictive');
      return UploadResult(
        url: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/500',
        path: 'demo/image.jpg',
      );
    }

    try {
      // Déterminer le type MIME depuis l'extension — fallback jpeg si inconnu
      final ext = file.path.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png'           => 'image/png',
        'webp'          => 'image/webp',
        _               => 'image/jpeg',
      };

      // Préparer la requête multipart
      final uri = Uri.parse('${AppConfig.apiUrl}/upload/image');
      debugPrint('UploadService: POST $uri | mimeType=$mimeType');
      final request = http.MultipartRequest('POST', uri);

      // Ajouter le token d'auth
      final token = ApiService.instance.accessToken ?? '';
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Ajouter le fichier avec le type MIME explicite
      final bytes = await file.readAsBytes();
      debugPrint('UploadService: fichier=${file.path.split('/').last} taille=${bytes.length}b');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final body = await response.stream.bytesToString();
      debugPrint('UploadService: response ${response.statusCode} — $body');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return UploadResult(
          url:  json['url'] as String,
          path: json['path'] as String,
        );
      } else {
        debugPrint('UploadService error: ${response.statusCode} $body');
        return null;
      }
    } catch (e) {
      debugPrint('UploadService exception: $e');
      return null;
    }
  }

  /// Upload plusieurs images en parallèle
  Future<List<String>> uploadImages(List<File> files) async {
    final results = await Future.wait(
      files.map((f) => uploadImage(f)),
    );
    return results
        .where((r) => r != null)
        .map((r) => r!.url)
        .toList();
  }

  /// Supprimer une image
  Future<void> deleteImage(String path) async {
    if (!AppConfig.useRealBackend) return;
    try {
      await ApiService.instance.delete('/upload/image?path=${Uri.encodeComponent(path)}');
    } catch (e) {
      debugPrint('UploadService deleteImage error: $e');
    }
  }

}
