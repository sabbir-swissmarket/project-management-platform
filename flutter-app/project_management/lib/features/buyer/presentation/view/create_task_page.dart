import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/buyer_provider.dart';

class CreateTaskPage extends ConsumerStatefulWidget {
  final String projectId;

  const CreateTaskPage({super.key, required this.projectId});

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final rateController = TextEditingController();
  final devController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Task")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Hourly Rate"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Hourly Rate required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: devController,
                decoration: const InputDecoration(labelText: "Developer ID"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Developer ID required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await ref
                      .read(buyerProvider.notifier)
                      .createTask(
                        projectId: widget.projectId,
                        title: titleController.text,
                        description: descController.text,
                        rate: double.parse(rateController.text),
                        developerId: devController.text,
                      );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Create Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
