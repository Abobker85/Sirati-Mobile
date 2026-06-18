import 'package:http/http.dart' as http;

import '../models/cv_analysis.dart';
import '../models/generated_cv.dart';
import 'api_client.dart';

class CvApiService {
  CvApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CvAnalysis> submitAnalysis({
    required String targetJobTitle,
    required String resumeText,
    http.MultipartFile? resumeFile,
  }) async {
    final response = await _apiClient.postMultipart(
      '/cv-analyses',
      fields: {
        'target_job_title': targetJobTitle,
        if (resumeText.trim().isNotEmpty) 'resume_text': resumeText.trim(),
      },
      file: resumeFile,
    );

    return CvAnalysis.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<CvAnalysis> getAnalysis(int id) async {
    final response = await _apiClient.getJson('/cv-analyses/$id');
    return CvAnalysis.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<CvAnalysis>> listAnalyses() async {
    final response = await _apiClient.getJson('/cv-analyses');
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CvAnalysis.fromJson)
        .toList();
  }

  Future<GeneratedCv> generateCv(Map<String, dynamic> payload) async {
    final response = await _apiClient.postJson('/generated-cvs', payload);
    return GeneratedCv.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<GeneratedCv> generateCvFromAnalysis({
    required int analysisId,
    required Map<String, dynamic> overrides,
  }) async {
    final response = await _apiClient.postJson(
      '/cv-analyses/$analysisId/generated-cv',
      overrides,
    );

    return GeneratedCv.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<GeneratedCv> getGeneratedCv(int id) async {
    final response = await _apiClient.getJson('/generated-cvs/$id');
    return GeneratedCv.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<GeneratedCv>> listGeneratedCvs() async {
    final response = await _apiClient.getJson('/generated-cvs');
    return (response['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(GeneratedCv.fromJson)
        .toList();
  }
}
