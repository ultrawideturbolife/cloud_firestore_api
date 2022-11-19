import 'package:firebase_core/firebase_core.dart';
import 'package:veto/data/models/base_view_model.dart';

import '../../../main.dart';

class CloudFirestoreApiViewModel extends BaseViewModel {
  CloudFirestoreApiViewModel();

  @override
  Future<void> initialise() async {
    await Firebase.initializeApp();
    ExampleAPI().createExample();
    super.initialise();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static CloudFirestoreApiViewModel get locate => CloudFirestoreApiViewModel();
}
