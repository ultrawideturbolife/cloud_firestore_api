import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_api/api/firestore_api.dart';
import 'package:example/cloud_firestore_api/views/cloud_firestore_api/cloud_firestore_api_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:turbo_response/turbo_response.dart';

import 'cloud_firestore_api/data/dtos/example_dto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class ExampleAPI extends FirestoreApi<ExampleDTO> {
  ExampleAPI()
      : super(
          collectionPath: () => 'Examples',
          firebaseFirestore: FirebaseFirestore.instance,
          fromJson: ExampleDTO.fromJson,
          toJson: (dto) => dto.toJson(),
        );

  Future<TurboResponse<DocumentReference>> createExample() {
    final random = Random();
    final dto = ExampleDTO(
      thisIsAString: ['yes', 'maybe'][random.nextInt(2)],
      thisIsANumber: random.nextDouble(),
      thisIsABoolean: random.nextBool(),
    );

    return createDoc(writeable: dto);
  }

  Future<TurboResponse<List<ExampleDTO>>> getAllExamples() {
    return findAllWithConverter();
  }

  static ExampleAPI get locate => ExampleAPI();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Firestore API Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CloudFirestoreApiView(),
    );
  }
}
