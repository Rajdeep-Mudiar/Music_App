import 'package:flutter/material.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/app_version_model.dart';
import 'package:resonance/services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final AppVersionModel versionInfo;
  final bool isForceUpdate;
  final UpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.isForceUpdate = false,
    required this.updateService,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate,
      child: AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update,
                  color: AppTheme.secondary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isForceUpdate ? 'Mandatory Update' : 'New Version Available',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Version ${versionInfo.latestVersion}',
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'What\'s New:',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              versionInfo.releaseNotes.isNotEmpty
                  ? versionInfo.releaseNotes
                  : 'New campus music features, improved study mode, and performance enhancements.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (isForceUpdate) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.accent, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This update is required to continue using Resonance campus features.',
                        style: TextStyle(color: AppTheme.accent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              updateService.launchUpdateUrl(versionInfo.downloadUrl);
              if (!isForceUpdate) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
