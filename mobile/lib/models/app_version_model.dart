class AppVersionModel {
  final String latestVersion;
  final String minimumSupportedVersion;
  final String releaseNotes;
  final String downloadUrl;

  AppVersionModel({
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    var android = json['android'] as Map<String, dynamic>? ?? {};
    return AppVersionModel(
      latestVersion: json['latest_version'] ?? '1.0.0',
      minimumSupportedVersion: json['minimum_supported_version'] ?? '1.0.0',
      releaseNotes: json['release_notes'] ?? '',
      downloadUrl: android['download_url'] ?? '',
    );
  }
}
