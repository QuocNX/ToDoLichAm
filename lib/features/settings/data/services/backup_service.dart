import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';
import 'package:todo_lich_am/features/todo/data/models/task_model.dart';

class BackupService extends GetxService {
  /// Exports all tasks to a JSON file and shares it.
  Future<void> exportData() async {
    try {
      final box = await Hive.openBox<TaskModel>(AppStrings.taskBoxName);
      final tasks = box.values.toList();

      if (tasks.isEmpty) {
        Get.snackbar('Thông báo', 'Không có dữ liệu để sao lưu');
        return;
      }

      // Convert tasks to JSON-encodable map
      final List<Map<String, dynamic>> jsonList = tasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'dueDate': task.dueDate.toIso8601String(),
          'time': task.time?.toIso8601String(),
          'isLunarCalendar': task.isLunarCalendar,
          'repeatType': task.repeatType,
          'isCompleted': task.isCompleted,
          'isStarred': task.isStarred,
          'category': task.category,
          'createdAt': task.createdAt.toIso8601String(),
          'completedAt': task.completedAt?.toIso8601String(),
          'lunarDay': task.lunarDay,
          'lunarMonth': task.lunarMonth,
          'lunarYear': task.lunarYear,
        };
      }).toList();

      final jsonString = jsonEncode(jsonList);

      // Create temporary file
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmm').format(now);
      final fileName = 'todo_backup_$formattedDate.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      // Share file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Backup data ToDoLichAm $formattedDate');
    } catch (e) {
      debugPrint('Export error: $e');
      Get.snackbar('Lỗi', 'Sao lưu thất bại: $e');
    }
  }

  /// Imports tasks from a JSON file.
  Future<void> importData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Decode
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<TaskModel> tasks = [];

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          tasks.add(
            TaskModel(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              description: item['description'],
              dueDate: DateTime.parse(item['dueDate']),
              time: item['time'] != null ? DateTime.parse(item['time']) : null,
              isLunarCalendar: item['isLunarCalendar'] ?? false,
              repeatType: item['repeatType'] ?? 'none',
              isCompleted: item['isCompleted'] ?? false,
              isStarred: item['isStarred'] ?? false,
              category: item['category'] ?? 'default',
              createdAt: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
              completedAt: item['completedAt'] != null
                  ? DateTime.parse(item['completedAt'])
                  : null,
              lunarDay: item['lunarDay'],
              lunarMonth: item['lunarMonth'],
              lunarYear: item['lunarYear'],
            ),
          );
        }
      }

      if (tasks.isEmpty) {
        Get.snackbar('Lỗi', 'File không chứa dữ liệu hợp lệ');
        return;
      }

      // Confirm restore
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Xác nhận khôi phục'),
          content: Text(
            'Tìm thấy ${tasks.length} công việc.\nDữ liệu hiện tại sẽ bị GHI ĐÈ hoặc HỢP NHẤT.\nBạn có muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Khôi phục'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final box = await Hive.openBox<TaskModel>(AppStrings.taskBoxName);

        // Strategy: Merge by ID. Update existing, add new.
        // Or clear all and add?
        // Let's clear all for "Restore" usually means replace state.
        // But safer is merge or replace.
        // Let's implement REPLACE strategy for simplicity and consistency with "Restore".
        // Or maybe ask user? For now, let's clear and add to correct duplicates.

        await box.clear();
        for (var task in tasks) {
          await box.put(task.id, task);
        }

        Get.snackbar('Thành công', 'Đã khôi phục ${tasks.length} công việc');

        // Refresh home controller if active
        // Get.find<HomeController>().loadTasks(); // Needs dependency
      }
    } catch (e) {
      debugPrint('Import error: $e');
      Get.snackbar('Lỗi', 'Khôi phục thất bại: $e');
    }
  }
}
