import 'package:flutter/material.dart';
import 'package:veto/data/models/base_view_model.dart';

import 'cloud_firestore_api_view_model.dart';

class CloudFirestoreApiView extends StatelessWidget {
  const CloudFirestoreApiView({Key? key}) : super(key: key);
  static const String route = 'cloud-firestore-api';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CloudFirestoreApiViewModel>(
      builder: (context, model, isInitialised, child) {
        return const Scaffold(
          body: Center(
            child: Text('oi'),
          ),
        );
      },
      viewModelBuilder: () => CloudFirestoreApiViewModel.locate,
    );
  }
}
