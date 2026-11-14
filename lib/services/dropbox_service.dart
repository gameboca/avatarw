import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../constants/api_constants.dart';

class DropboxService {
  static final DropboxService instance = DropboxService._();
  DropboxService._();

  String? _accessToken;
  DateTime? _tokenExpiry;

  // In-memory cache for fast UI image rendering
  final Map<String, Uint8List> _memoryCache = {};

  Future<String?> getValidToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.dropboxTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': ApiConstants.refreshToken,
          'client_id': ApiConstants.clientId,
          'client_secret': ApiConstants.clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int? ?? 14400;
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: expiresIn - 300));
        return _accessToken;
      } else {
        debugPrint('Failed to refresh Dropbox token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Dropbox token refresh error: $e');
    }
    return _accessToken;
  }

  Future<Uint8List?> fetchFileBytes(String remotePath) async {
    // 1. Check memory cache
    if (_memoryCache.containsKey(remotePath)) {
      return _memoryCache[remotePath];
    }

    // 2. Check bundled offline asset fallback
    final filename = remotePath.split('/').last;
    try {
      final assetData =
          await rootBundle.load('assets/images/offline_cache/$filename');
      final bytes = assetData.buffer.asUint8List();
      _memoryCache[remotePath] = bytes;
      return bytes;
    } catch (_) {
      // not in local offline cache, proceed to Dropbox network fetch
    }

    // 3. Fetch from Dropbox API
    final token = await getValidToken();
    if (token == null) return null;

    try {
      final argJson = json.encode({
        'url': ApiConstants.dropboxSharedLink,
        'path': remotePath,
      });

      final response = await http.post(
        Uri.parse(ApiConstants.dropboxDownloadUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Dropbox-API-Arg': argJson,
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _memoryCache[remotePath] = bytes;
        return bytes;
      } else {
        debugPrint('Dropbox fetch error [$remotePath]: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Dropbox error downloading $remotePath: $e');
    }

    return null;
  }

  Future<XFile?> downloadToFile(
    String remotePath,
    String fileName, {
    Function(double progress)? onProgress,
  }) async {
    final token = await getValidToken();
    if (token == null) return null;

    try {
      final argJson = json.encode({
        'url': ApiConstants.dropboxSharedLink,
        'path': remotePath,
      });

      final request =
          http.Request('POST', Uri.parse(ApiConstants.dropboxDownloadUrl))
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Dropbox-API-Arg'] = argJson;

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final totalBytes = streamedResponse.contentLength ?? 0;
        int receivedBytes = 0;
        final List<int> bytes = [];

        await for (final chunk in streamedResponse.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0 && onProgress != null) {
            onProgress(receivedBytes / totalBytes);
          }
        }

        final uint8 = Uint8List.fromList(bytes);
        _memoryCache[remotePath] = uint8;
        return XFile.fromData(uint8, name: fileName);
      }
    } catch (e) {
      debugPrint('Error streaming download $remotePath: $e');
    }
    return null;
  }
}
