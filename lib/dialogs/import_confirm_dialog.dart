import 'package:flutter/material.dart';

import '../services/backup_service.dart';

/// 导入备份前的确认弹窗
///
/// 展示备份内容概要，并明确提示会覆盖当前全部数据，避免误操作造成数据丢失。
class ImportConfirmDialog extends StatelessWidget {
  /// 已解析并校验通过的备份内容
  final BackupPayload payload;

  /// 创建ImportConfirmDialog实例
  const ImportConfirmDialog({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profileText = payload.userProfile == null ? '无' : '有';
    final exportedAt = payload.exportedAt ?? '未知';

    return AlertDialog(
      title: const Text('确认导入备份'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用药提醒：${payload.medicines.length} 条'),
            const SizedBox(height: 4),
            Text('健康记录：${payload.healthRecords.length} 条'),
            const SizedBox(height: 4),
            Text('用户档案：$profileText'),
            const SizedBox(height: 4),
            Text(
              '备份导出时间：$exportedAt',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              '导入将覆盖当前的全部本地数据，且无法撤销。',
              style: TextStyle(color: cs.error),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('确认导入'),
        ),
      ],
    );
  }
}
