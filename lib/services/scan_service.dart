import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'package:PlantPulse/state/scan_record.dart';

class ScanApiResult {
  final String status;
  final String confidence;
  final String? diseaseName;
  final String? description;
  final String? treatment;
  final bool isNotLettuce;
  final String? error;
  final bool isNetworkError;

  const ScanApiResult({
    this.status = 'Healthy',
    this.confidence = '0',
    this.diseaseName,
    this.description,
    this.treatment,
    this.isNotLettuce = false,
    this.error,
    this.isNetworkError = false,
  });
}

const _baseUrl = 'https://plant-pules-api.vercel.app/api/v1';
const _predictUrl = '$_baseUrl/scan/predict';

Future<ScanApiResult> runScanApi(String imagePath) async {
  try {
    final dio = Dio();
    final formData = FormData.fromMap({
      'images': await MultipartFile.fromFile(imagePath),
    });

    final response = await dio.post(
      _predictUrl,
      data: formData,
      options: Options(
        headers: {'token': userState.token},
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final data = response.data['data'];
    final decision = (data?['finalDecision'] as String? ?? '').toLowerCase();
    final confidenceNum = (data?['averageConfidence'] as num? ?? 0);
    final results = data?['results'] as List?;
    final firstResult = results?.isNotEmpty == true
        ? results!.first as Map<String, dynamic>?
        : null;

    if (decision == 'not_lettuce') {
      return const ScanApiResult(isNotLettuce: true);
    }

    return ScanApiResult(
      status: decision == 'healthy' ? 'Healthy' : 'Diseased',
      confidence: confidenceNum.toStringAsFixed(0),
      diseaseName: firstResult?['disease_name']?.toString(),
      description: firstResult?['description']?.toString(),
      treatment: firstResult?['treatment']?.toString(),
    );
  } on DioException catch (e) {
    String errorMsg;
    bool isNetwork = false;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMsg = 'Connection timed out. Please check your internet and try again.';
        isNetwork = true;
        break;
      case DioExceptionType.connectionError:
        errorMsg = 'No internet connection. Please try again.';
        isNetwork = true;
        break;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        errorMsg = code >= 500
            ? 'Server error. Please try again in a moment.'
            : code == 401
            ? 'Session expired. Please log in again.'
            : 'Something went wrong. Please try again.';
        break;
      default:
        errorMsg = 'Something went wrong. Please try again.';
    }

    return ScanApiResult(error: errorMsg, isNetworkError: isNetwork);
  } catch (_) {
    return const ScanApiResult(error: 'Something went wrong. Please try again.');
  }
}

Future<void> loadScansFromApi(String token, {bool forceRefresh = false}) async {
  if (token.isEmpty) return;
  if (!forceRefresh && scansState.isNotEmpty) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList('deletedScanIds') ?? [];

    final dio = Dio();
    final response = await dio.get(
      'https://plant-pules-api.vercel.app/api/v1/scan/recent',
      options: Options(headers: {'token': token}),
    );
    final List data = response.data['data'] ?? [];
    final apiScans = data
        .map((s) => ScanRecord.fromJson(s as Map<String, dynamic>))
        .where((s) => s.status == 'Healthy' || s.status == 'Diseased')
        .where((s) => s.id == null || !deletedIds.contains(s.id))
        .toList();
    scansState.setAll(apiScans);
    await saveScans();
  } catch (_) {}
}