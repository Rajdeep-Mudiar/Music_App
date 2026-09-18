import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/app_version_model.dart';

enum UpdateStatus {
  upToDate,
  updateAvailable,
  forceUpdateRequired,
}

class UpdateCheckResult {
  final UpdateStatus status;
  final String currentVersion;
  final AppVersionModel? versionInfo;

  UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.versionInfo,
  });
}

class UpdateService {
  final ApiClient apiClient;

  UpdateService({required this.apiClient});

  Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion =
          packageInfo.version.isNotEmpty ? packageInfo.version : '1.0.0';

      final res = await apiClient.dio.get(ApiConstants.appVersion);
      if (res.statusCode == 200) {
        final versionInfo = AppVersionModel.fromJson(res.data);

        if (_isVersionLower(
            currentVersion, versionInfo.minimumSupportedVersion)) {
          return UpdateCheckResult(
            status: UpdateStatus.forceUpdateRequired,
            currentVersion: currentVersion,
            versionInfo: versionInfo,
          );
        } else if (_isVersionLower(currentVersion, versionInfo.latestVersion)) {
          return UpdateCheckResult(
            status: UpdateStatus.updateAvailable,
            currentVersion: currentVersion,
            versionInfo: versionInfo,
          );
        }
      }
    } catch (_) {}

    return UpdateCheckResult(
      status: UpdateStatus.upToDate,
      currentVersion: '1.0.0',
    );
  }

  bool _isVersionLower(String current, String target) {
    try {
      List<int> currentParts =
          current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> targetParts =
          target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (targetParts.length < 3) {
        targetParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (currentParts[i] < targetParts[i]) return true;
        if (currentParts[i] > targetParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
