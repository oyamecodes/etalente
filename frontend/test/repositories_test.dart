import 'dart:convert';

import 'package:etalente/core/api/api_client.dart';
import 'package:etalente/core/api/api_exception.dart';
import 'package:etalente/features/assistant/data/assistant_api.dart';
import 'package:etalente/features/assistant/data/assistant_repository.dart';
import 'package:etalente/features/jobs/data/job_api.dart';
import 'package:etalente/features/jobs/data/job_repository.dart';
import 'package:etalente/features/stats/data/stats_api.dart';
import 'package:etalente/features/stats/data/stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Builds an [ApiClient] backed by an [http.MockClient] so wire
/// contracts can be exercised without hitting a real server. Each test
/// supplies a handler that receives the outbound [http.Request] and
/// returns a stubbed [http.Response].
ApiClient _client(Future<http.Response> Function(http.Request) handler) {
  return ApiClient(
    httpClient: MockClient((req) => handler(req)),
    baseUrl: 'http://test.local',
  );
}

void main() {
  group('JobRepository', () {
    test('GET /api/jobs drops null/empty query params and parses page',
        () async {
      late Uri seenUri;
      late Map<String, String> seenHeaders;
      final client = _client((req) async {
        seenUri = req.url;
        seenHeaders = req.headers;
        return http.Response(
          jsonEncode({
            'content': [
              {
                'id': 'job-1',
                'title': 'Flutter Eng',
                'location': 'Cape Town',
                'type': 'Full-time',
                'experience': '5+ Years',
                'salaryRange': 'R900k',
                'postedBy': 'Enviro365',
                'closingDate': '2026-06-30',
              },
            ],
            'page': 0,
            'size': 100,
            'total': 1,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = JobRepository(JobApi(client));

      final page = await repo.listJobs(
        type: 'Contract',
        experience: null,
        location: '',
        search: 'flutter',
        size: 100,
        bearerToken: 'abc',
      );

      expect(seenUri.path, '/api/jobs');
      // null + empty-string params must not appear; page/size always do.
      expect(seenUri.queryParameters, {
        'type': 'Contract',
        'search': 'flutter',
        'page': '0',
        'size': '100',
      });
      expect(seenHeaders['Authorization'], 'Bearer abc');
      expect(page.total, 1);
      expect(page.content.single.title, 'Flutter Eng');
    });

    test('non-2xx response surfaces the backend error envelope message',
        () async {
      final client = _client((_) async => http.Response(
            jsonEncode({
              'timestamp': '2026-04-23T00:00:00Z',
              'status': 400,
              'error': 'Bad Request',
              'message': 'Invalid experience filter',
              'path': '/api/jobs',
            }),
            400,
            headers: {'content-type': 'application/json'},
          ));
      final repo = JobRepository(JobApi(client));

      await expectLater(
        repo.listJobs(),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message',
                'Invalid experience filter')),
      );
    });
  });

  group('StatsRepository', () {
    test('GET /api/stats parses the three counters', () async {
      final client = _client((req) async {
        expect(req.url.path, '/api/stats');
        expect(req.headers['Authorization'], 'Bearer tkn');
        return http.Response(
          jsonEncode({
            'activePosts': 12,
            'newApplicants': 48,
            'interviewsToday': 3,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = StatsRepository(StatsApi(client));

      final stats = await repo.fetch(bearerToken: 'tkn');

      expect(stats.activePosts, 12);
      expect(stats.newApplicants, 48);
      expect(stats.interviewsToday, 3);
    });
  });

  group('AssistantRepository', () {
    test('POST /api/assistant/message sends {message} and parses reply',
        () async {
      final client = _client((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/api/assistant/message');
        expect(jsonDecode(req.body), {'message': 'hi'});
        return http.Response(
          jsonEncode({
            'reply': 'Hello there',
            'timestamp': '2026-04-23T00:00:00Z',
            'source': 'canned',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = AssistantRepository(AssistantApi(client));

      final reply = await repo.sendMessage('hi');

      expect(reply.reply, 'Hello there');
      expect(reply.source, 'canned');
    });
  });
}
