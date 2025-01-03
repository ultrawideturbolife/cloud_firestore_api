import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/cloud_firestore_api/data/dtos/example_dto.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';

class CloudFirestoreApiView extends StatelessWidget {
  const CloudFirestoreApiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Firestore API Example')),
      body: StreamBuilder<List<ExampleDTO>>(
        stream: ExampleAPI.locate.findStreamWithConverter(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final examples = snapshot.data!;

          if (examples.isEmpty) {
            return const Center(
              child: Text('No examples yet. Add some using the + button!'),
            );
          }

          return ListView.builder(
            itemCount: examples.length,
            itemBuilder: (context, index) {
              final example = examples[index];
              return ListTile(
                title: Text('String: ${example.thisIsAString}'),
                subtitle: Text(
                  'Number: ${example.thisIsANumber.toStringAsFixed(2)}\n'
                  'Boolean: ${example.thisIsABoolean}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final response = await ExampleAPI.locate.createExample();

          if (!context.mounted) return;

          response.when(
            success: (_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Example created successfully!')),
            ),
            fail: (error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
