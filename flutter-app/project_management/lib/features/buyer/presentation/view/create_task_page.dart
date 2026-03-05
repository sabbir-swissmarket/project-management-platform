import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/developer_model.dart';
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
  final _formKey = GlobalKey<FormState>();

  String? _selectedDeveloperId;
  late Future<List<Developer>> _developersFuture;

  @override
  void initState() {
    super.initState();
    _developersFuture = _loadDevelopers();
  }

  Future<List<Developer>> _loadDevelopers() {
    return ref.read(buyerProvider.notifier).fetchDevelopers();
  }

  void _retryLoadDevelopers() {
    setState(() {
      _developersFuture = _loadDevelopers();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    rateController.dispose();
    super.dispose();
  }

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

              FutureBuilder<List<Developer>>(
                future: _developersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Failed to load developers",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          TextButton(
                            onPressed: _retryLoadDevelopers,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final developers = snapshot.data ?? [];

                  if (developers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("No developers available."),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedDeveloperId,
                    decoration: const InputDecoration(
                      labelText: "Assign Developer",
                    ),
                    isExpanded: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a developer";
                      }
                      return null;
                    },
                    items: developers
                        .map(
                          (dev) => DropdownMenuItem(
                            value: dev.id,
                            child: Text(dev.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDeveloperId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final developerId = _selectedDeveloperId;
                  if (developerId == null) return;

                  await ref
                      .read(buyerProvider.notifier)
                      .createTask(
                        projectId: widget.projectId,
                        title: titleController.text,
                        description: descController.text,
                        rate: double.parse(rateController.text),
                        developerId: developerId,
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
