import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sirati/services/api_client.dart';
import 'package:sirati/services/api_exception.dart';
import 'package:sirati/services/cv_api_service.dart';

void main() {
  group('CvApiService', () {
    test('lists CV analyses from Laravel resource collection JSON', () async {
      final service = CvApiService(
        apiClient: ApiClient(
          httpClient: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/api/cv-analyses');

            return _jsonResponse({
              'data': [
                _analysisJson(id: 7, targetJobTitle: 'Laravel Developer'),
              ],
            });
          }),
        ),
      );

      final analyses = await service.listAnalyses();

      expect(analyses, hasLength(1));
      expect(analyses.single.id, 7);
      expect(analyses.single.targetJobTitle, 'Laravel Developer');
      expect(analyses.single.criteria.single.label, 'Keywords');
      expect(analyses.single.inputMethodLabel, 'لصق نص');
    });

    test('submits analysis as multipart request', () async {
      final service = CvApiService(
        apiClient: ApiClient(
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.path, '/api/cv-analyses');
            expect(request.headers['content-type'],
                contains('multipart/form-data'));

            final body = request is http.Request ? request.body : '';
            expect(body, contains('name="target_job_title"'));
            expect(body, contains('Data Analyst'));
            expect(body, contains('name="resume_text"'));
            expect(body, contains('Resume text'));

            return _jsonResponse(
                {'data': _analysisJson(targetJobTitle: 'Data Analyst')},
                statusCode: 201);
          }),
        ),
      );

      final analysis = await service.submitAnalysis(
        targetJobTitle: 'Data Analyst',
        resumeText: '  Resume text  ',
      );

      expect(analysis.targetJobTitle, 'Data Analyst');
      expect(analysis.scoreTotal, 82);
    });

    test('generates CV from JSON payload', () async {
      final service = CvApiService(
        apiClient: ApiClient(
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.path, '/api/generated-cvs');
            expect(
                request.headers['content-type'], contains('application/json'));

            final payload = jsonDecode(request.body) as Map<String, dynamic>;
            expect(payload['full_name'], 'Salem Sayer');
            expect(payload['language'], 'en');

            return _jsonResponse({'data': _generatedCvJson()}, statusCode: 201);
          }),
        ),
      );

      final generatedCv = await service.generateCv({
        'full_name': 'Salem Sayer',
        'target_job_title': 'Backend Developer',
        'language': 'en',
        'skills_input': 'PHP, Laravel, APIs',
        'experience_input':
            'Built backend APIs for internal teams with measurable outcomes.',
        'education_input': 'BSc Computer Science',
      });

      expect(generatedCv.id, 9);
      expect(generatedCv.fullName, 'Salem Sayer');
      expect(
          generatedCv.pdfUrl, 'http://localhost:8000/api/generated-cvs/9/pdf');
    });

    test('throws displayable Laravel validation errors', () async {
      final service = CvApiService(
        apiClient: ApiClient(
          httpClient: MockClient((request) async {
            return _jsonResponse({
              'message': 'The resume text field is required.',
              'errors': {
                'resume_text': ['Paste resume text or upload a file.'],
              },
            }, statusCode: 422);
          }),
        ),
      );

      expect(
        () => service.submitAnalysis(
            targetJobTitle: 'Backend Developer', resumeText: ''),
        throwsA(
          isA<ApiException>().having(
            (exception) => exception.displayMessage,
            'displayMessage',
            'Paste resume text or upload a file.',
          ),
        ),
      );
    });
  });
}

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> _analysisJson({
  int id = 1,
  String targetJobTitle = 'Backend Developer',
}) {
  return {
    'id': id,
    'target_job_title': targetJobTitle,
    'original_filename': null,
    'input_method': 'paste',
    'score_total': 82,
    'grade': 'B+',
    'job_match': 85,
    'criteria': [
      {'label': 'Keywords', 'score': 25, 'max': 30},
    ],
    'strengths': ['Strong keyword coverage'],
    'weaknesses': [
      {'priority': 'high', 'issue': 'Missing metrics', 'fix': 'Add numbers'},
    ],
    'keywords_found': ['Laravel', 'API'],
    'keywords_missing': ['Docker'],
    'quick_wins': ['Add Docker'],
    'ai_status': 'not_configured',
    'ai_feedback': null,
    'ai_error': null,
    'created_at': '2026-06-18T08:00:00.000000Z',
    'updated_at': '2026-06-18T08:00:00.000000Z',
  };
}

Map<String, dynamic> _generatedCvJson() {
  return {
    'id': 9,
    'full_name': 'Salem Sayer',
    'email': 'salem@example.com',
    'phone': '+966500000000',
    'linkedin': 'linkedin.com/in/salem',
    'location': 'Riyadh',
    'target_job_title': 'Backend Developer',
    'language': 'en',
    'generated_markdown': '# Salem Sayer\n\n## Experience\nBuilt APIs.',
    'ai_status': 'not_configured',
    'ai_output': null,
    'ai_error': null,
    'score_total': 88,
    'grade': 'A',
    'criteria': [
      {'label': 'Keywords', 'score': 28, 'max': 30},
    ],
    'pdf_url': 'http://localhost:8000/api/generated-cvs/9/pdf',
    'created_at': '2026-06-18T08:00:00.000000Z',
    'updated_at': '2026-06-18T08:00:00.000000Z',
  };
}
