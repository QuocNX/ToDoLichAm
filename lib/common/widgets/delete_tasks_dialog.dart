import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';

/// Dialog for selecting task deletion options.
class DeleteTasksDialog extends StatefulWidget {
  const DeleteTasksDialog({super.key});

  @override
  State<DeleteTasksDialog> createState() => _DeleteTasksDialogState();
}

class _DeleteTasksDialogState extends State<DeleteTasksDialog> {
  bool _deleteAll = false;
  bool _deleteCompleted = true;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final isVi = settings.locale.value == 'vi';

    return AlertDialog(
      title: Text(isVi ? 'Xóa công việc' : 'Delete Tasks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: Text(isVi ? 'Xóa toàn bộ việc' : 'Delete all tasks'),
            value: _deleteAll,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _deleteAll = value ?? false;
                if (_deleteAll) {
                  _deleteCompleted =
                      true; // If deleting all, completed are also included
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text(
              isVi
                  ? 'Xóa toàn bộ việc đã hoàn thành'
                  : 'Delete only completed tasks',
            ),
            value: _deleteCompleted,
            activeColor: AppColors.primary,
            enabled: !_deleteAll, // If deleting all, this is redundant
            onChanged: (value) {
              setState(() {
                _deleteCompleted = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(isVi ? 'Hủy' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: (!_deleteAll && !_deleteCompleted)
              ? null
              : () => Get.back(
                  result: {
                    'deleteAll': _deleteAll,
                    'deleteCompleted': _deleteCompleted,
                  },
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(isVi ? 'Xóa' : 'Delete'),
        ),
      ],
    );
  }
}
