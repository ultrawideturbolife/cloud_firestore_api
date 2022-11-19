import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/abstracts/writeable.dart';
import 'package:cloud_firestore_api/api/firestore_api.dart';
import 'package:example/cloud_firestore_api/views/cloud_firestore_api/cloud_firestore_api_view.dart';
import 'package:flutter/material.dart';

import 'cloud_firestore_api/data/dtos/example_dto.dart';

void main() async {
  runApp(const MyApp());
}

class CreateExampleRequest extends Writeable {
  CreateExampleRequest({
    required this.exampleDTO,
  });

  final ExampleDTO exampleDTO;

  @override
  Map<String, dynamic> toJson() => exampleDTO.toJson();
}

class ExampleAPI extends FirestoreAPI<ExampleDTO> {
  ExampleAPI()
      : super(
          collectionPath: 'Examples',
          firebaseFirestore: FirebaseFirestore.instance,
          fromJson: ExampleDTO.fromJson,
        );

  void createExample() {
    final random = Random();
    create(
      writeable: CreateExampleRequest(
        exampleDTO: ExampleDTO(
          thisIsABoolean: random.nextBool(),
          thisIsANumber: random.nextDouble(),
          thisIsAString: ['yes', 'maybe'][random.nextInt(2)],
        ),
      ),
    );
  }

  static ExampleAPI get locate => ExampleAPI();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CloudFirestoreApiView(),
    );
  }
}
