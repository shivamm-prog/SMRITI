import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/connectivity_state.dart';
import '../services/local_data_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.state});
  final SmritiConnectionState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final data = LocalDataService.instance;
        final isOnline = data.isOnline;
        final isSyncing = data.isSyncing;
        final pendingCount = data.pendingSyncCount;

        final color = isOnline ? AppColors.success : AppColors.offline;
        String title;
        String detail;

        if (isSyncing) {
          title = 'Syncing With MindSetu Cloud...';
          detail = 'Updating cognitive routines and records.';
        } else if (isOnline) {
          title = 'FastAPI Cloud Connected';
          detail = 'Activities & clinical logs sync in real time.';
        } else {
          title = 'Offline Mode Active';
          detail = pendingCount > 0
              ? '$pendingCount pending change(s) queued for sync when online.'
              : 'Your activities continue working safely without internet.';
        }

        return Semantics(
          label: '$title. $detail',
          child: InkWell(
            onTap: () => data.syncWithBackend(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(.22)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSyncing
                        ? Icons.sync
                        : (isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined),
                    color: color,
                    size: 25,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
                        const SizedBox(height: 2),
                        Text(detail, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.charcoal, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (!isSyncing)
                    TextButton(
                      onPressed: () => data.syncWithBackend(),
                      child: Text(
                        isOnline ? 'Sync' : 'Retry',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
