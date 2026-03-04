import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/developer_provider.dart';

class SubmitTaskPage extends ConsumerStatefulWidget {
  final String taskId;

  const SubmitTaskPage({super.key, required this.taskId});

  @override
  ConsumerState<SubmitTaskPage> createState() => _SubmitTaskPageState();
}

class _SubmitTaskPageState extends ConsumerState<SubmitTaskPage> {
  final hoursController = TextEditingController();
  String? selectedFilePath;

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(developerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Submit Task")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hours Input
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Hours Worked"),
            ),

            const SizedBox(height: 20),

            // File Picker Button
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  setState(() {
                    selectedFilePath = result.files.single.path;
                  });
                }
              },
              child: const Text("Choose ZIP File"),
            ),

            if (selectedFilePath != null) Text("Selected: $selectedFilePath"),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: submitState is AsyncLoading
                  ? null
                  : () async {
                      if (selectedFilePath == null) return;

                      await ref
                          .read(developerProvider.notifier)
                          .submitTask(
                            taskId: widget.taskId,
                            hours: double.parse(hoursController.text),
                            filePath: selectedFilePath!,
                          );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: submitState is AsyncLoading
                  ? const CircularProgressIndicator()
                  : const Text("Submit Task"),
            ),
          ],
        ),
      ),
    );
  }
}
