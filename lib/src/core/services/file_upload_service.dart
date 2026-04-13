// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Cloudinary-based file upload service.
/// Uploads files directly from the browser → Cloudinary → returns a permanent URL.
///
/// Setup: Create a free Cloudinary account at https://cloudinary.com
/// 1. Go to Settings → Upload → Add upload preset → Set to "Unsigned"
/// 2. Copy your cloud name and preset name below.
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  // ── CLOUDINARY CONFIGURATION ─────────────────────────
  String _cloudName = 'dklnaegqd';
  String _uploadPreset = 'ksrce_unsigned';

  String get cloudName => _cloudName;
  String get uploadPreset => _uploadPreset;
  bool get isConfigured => _cloudName.isNotEmpty && _uploadPreset.isNotEmpty;

  void configure({required String cloudName, required String uploadPreset}) {
    _cloudName = cloudName;
    _uploadPreset = uploadPreset;
  }

  /// Pick a file using browser file picker.
  /// Returns the selected file or null if cancelled.
  Future<html.File?> pickFile({String accept = '*/*'}) async {
    final input = html.FileUploadInputElement()..accept = accept;
    input.click();
    await input.onChange.first;
    final files = input.files;
    if (files == null || files.isEmpty) return null;
    return files[0];
  }

  /// Pick an image file.
  Future<html.File?> pickImage() => pickFile(accept: 'image/*');

  /// Pick a document file (PDF, DOC, etc.).
  Future<html.File?> pickDocument() =>
      pickFile(accept: '.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv');

  /// Upload a file to Cloudinary and return the result.
  /// Returns a map with: { url, publicId, originalName, format, size, resourceType }
  /// Throws on network error or Cloudinary rejection.
  Future<UploadResult> uploadFile(
    html.File file, {
    String? folder,
    void Function(double progress)? onProgress,
  }) async {
    if (!isConfigured) {
      throw Exception(
          'Cloudinary not configured. Call FileUploadService().configure(cloudName: ..., uploadPreset: ...) first.');
    }

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload');

    // Read file bytes
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;
    final bytes = (reader.result as dynamic);

    // Build multipart request
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    if (folder != null) request.fields['folder'] = folder;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      List<int>.from(bytes as Iterable),
      filename: file.name,
    ));

    // Send
    onProgress?.call(0.3); // Indicate upload started
    final streamedResponse = await request.send();
    onProgress?.call(0.8);
    final responseBody = await streamedResponse.stream.bytesToString();
    onProgress?.call(1.0);

    if (streamedResponse.statusCode != 200) {
      final errorData = json.decode(responseBody);
      throw Exception(
          'Upload failed: ${errorData['error']?['message'] ?? responseBody}');
    }

    final data = json.decode(responseBody) as Map<String, dynamic>;
    return UploadResult(
      url: data['secure_url'] as String,
      publicId: data['public_id'] as String,
      originalName: file.name,
      format: data['format'] as String? ?? _getExtension(file.name),
      sizeBytes: data['bytes'] as int? ?? file.size,
      resourceType: data['resource_type'] as String? ?? 'raw',
      width: data['width'] as int?,
      height: data['height'] as int?,
    );
  }

  /// Upload an image and return the URL.
  Future<String> uploadImageAndGetUrl(html.File file, {String? folder}) async {
    final result = await uploadFile(file, folder: folder ?? 'ksrce/images');
    return result.url;
  }

  /// Upload a document and return the URL.
  Future<String> uploadDocumentAndGetUrl(html.File file,
      {String? folder}) async {
    final result = await uploadFile(file, folder: folder ?? 'ksrce/documents');
    return result.url;
  }

  /// Get file size as human-readable string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get appropriate icon for a file type.
  static IconData getFileIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

/// Result of a successful file upload.
class UploadResult {
  final String url;
  final String publicId;
  final String originalName;
  final String format;
  final int sizeBytes;
  final String resourceType;
  final int? width;
  final int? height;

  const UploadResult({
    required this.url,
    required this.publicId,
    required this.originalName,
    required this.format,
    required this.sizeBytes,
    required this.resourceType,
    this.width,
    this.height,
  });

  Map<String, dynamic> toMap() => {
        'url': url,
        'publicId': publicId,
        'originalName': originalName,
        'format': format,
        'sizeBytes': sizeBytes,
        'resourceType': resourceType,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      };

  bool get isImage => resourceType == 'image';
  String get formattedSize => FileUploadService.formatFileSize(sizeBytes);
}
