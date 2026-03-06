import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/data/models/developer_model.dart';
import '../../../shared/data/models/project_model.dart';
import '../../../shared/data/models/task_model.dart';
import '../../../shared/domain/entities/developer.dart';
import '../../../shared/domain/entities/project.dart';
import '../../../shared/domain/entities/task.dart';
import '../../domain/repositories/buyer_repository.dart';

class BuyerRepositoryImpl implements BuyerRepository {
  BuyerRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> createProject(String title, String description) async {
    await _dio.post(
      '/projects',
      data: {'title': title, 'description': description},
    );
  }

  @override
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double hourlyRate,
    required String developerId,
  }) async {
    await _dio.post(
      '/tasks',
      data: {
        'project_id': projectId,
        'title': title,
        'description': description,
        'hourly_rate': hourlyRate,
        'assigned_developer_id': developerId,
      },
    );
  }

  @override
  Future<String> downloadSolution(String taskId) async {
    final response = await _dio.get<List<int>>(
      '/tasks/$taskId/download',
      options: Options(responseType: ResponseType.bytes),
    );

    final fileName = _resolveFileName(
      response.headers.value('content-disposition'),
      taskId,
    );

    final directory = await _resolveDownloadDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsBytes(response.data ?? <int>[], flush: true);

    return file.path;
  }

  @override
  Future<List<Developer>> fetchDevelopers() async {
    final response = await _dio.get('/developers');

    return (response.data as List<dynamic>)
        .map((e) => DeveloperModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Project>> fetchProjects() async {
    final response = await _dio.get('/projects');

    return (response.data as List<dynamic>)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> fetchTasks(String projectId) async {
    final response = await _dio.get('/projects/$projectId/tasks');

    return (response.data as List<dynamic>)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> payForTask(String taskId) async {
    await _dio.post('/payments/$taskId');
  }

  String _resolveFileName(String? header, String taskId) {
    if (header != null) {
      final encodedMatch =
          RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(header);
      if (encodedMatch != null) {
        final encodedValue = encodedMatch.group(1);
        if (encodedValue != null && encodedValue.isNotEmpty) {
          return Uri.decodeComponent(encodedValue);
        }
      }

      final plainMatch = RegExp(r'filename="?([^";]+)"?').firstMatch(header);
      if (plainMatch != null) {
        final value = plainMatch.group(1);
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return 'task_$taskId.zip';
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      await _ensureStoragePermission();

      final directories = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );

      if (directories != null && directories.isNotEmpty) {
        return directories.first;
      }

      final fallback = Directory('/storage/emulated/0/Download');
      if (!await fallback.exists()) {
        await fallback.create(recursive: true);
      }
      return fallback;
    }

    if (Platform.isIOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${docsDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir;
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }

    return getApplicationDocumentsDirectory();
  }

  Future<void> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return;

    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return;
    }

    var manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      manageStatus = await Permission.manageExternalStorage.request();
    }

    if (!manageStatus.isGranted) {
      throw Exception(
        'Storage permission is required to save downloads. Please enable it in Settings.',
      );
    }
  }
}
