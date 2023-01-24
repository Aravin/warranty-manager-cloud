import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyWidget extends StatelessWidget {
  const MyWidget(
      {super.key, bool? isUpdate, Function(bool rebuild)? actionCallback});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
