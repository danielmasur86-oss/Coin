import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/explanation.dart';
import '../models/profile.dart';

enum ApiErrorKind { limitReached, busy, network, generic }

class ApiException implements Exception {
  ApiException(this.kind);
  final ApiErrorKind kind;
}

class ExplainResult {
  ExplainResult(this.explanation, this.remainingFree);
  final Explanation explanation;
  final int? remainingFree; // null = premium
}

class QuotaInfo {
  QuotaInfo({required this.premium, required this.remainingFree});
  final bool premium;
  final int? remainingFree;
}

class ApiClient {
  ApiClient({required this.userId, http.Client? client}) : _http = client ?? http.Client();

  final String userId;
  final http.Client _http;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'x-user-id': userId,
      };

  Future<QuotaInfo> quota() async {
    final res = await _send(() => _http.get(_uri('/v1/quota'), headers: _headers));
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return QuotaInfo(premium: j['premium'] as bool, remainingFree: j['remainingFree'] as int?);
  }

  Future<ExplainResult> explain({
    required List<int> jpegBytes,
    required Profile profile,
    required String subject,
    required String mode,
  }) async {
    final body = jsonEncode({
      'imageBase64': base64Encode(jpegBytes),
      'mediaType': 'image/jpeg',
      'mode': mode,
      'parentLanguage': profile.language,
      'bundesland': profile.bundesland,
      'schoolType': profile.schoolType,
      'grade': profile.grade,
      'subject': subject,
    });
    final res = await _send(
      () => _http.post(_uri('/v1/explain'), headers: _headers, body: body),
      timeout: const Duration(seconds: 120),
    );
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return ExplainResult(
      Explanation.fromJson((j['explanation'] as Map).cast<String, dynamic>()),
      j['remainingFree'] as int?,
    );
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    http.Response res;
    try {
      res = await request().timeout(timeout);
    } on SocketException {
      throw ApiException(ApiErrorKind.network);
    } on http.ClientException {
      throw ApiException(ApiErrorKind.network);
    } on Exception {
      throw ApiException(ApiErrorKind.network);
    }
    if (res.statusCode == 200) return res;
    if (res.statusCode == 402) throw ApiException(ApiErrorKind.limitReached);
    if (res.statusCode == 503) throw ApiException(ApiErrorKind.busy);
    throw ApiException(ApiErrorKind.generic);
  }
}
