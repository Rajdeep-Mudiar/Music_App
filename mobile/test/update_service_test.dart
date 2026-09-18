import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/models/app_version_model.dart';

void main() {
  group('AppVersionModel Tests', () {
    test('Correctly parses JSON response from backend /api/app/version', () {
      final json = {
        'latest_version': '1.0.3',
        'minimum_supported_version': '1.0.0',
        'release_notes': 'Performance improvements and campus playlists.',
        'android': {
          'download_url': 'https://github.com/resonance-app/resonance/releases/download/v1.0.3/app-release.apk'
        }
      };

      final model = AppVersionModel.fromJson(json);

      expect(model.latestVersion, equals('1.0.3'));
      expect(model.minimumSupportedVersion, equals('1.0.0'));
      expect(model.releaseNotes, contains('Performance improvements'));
      expect(model.downloadUrl, contains('v1.0.3'));
    });
  });
}
