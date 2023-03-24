import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';

final appLoader = SpinKitThreeBounce(
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? kAccentColor : kPrimaryColor,
      ),
    );
  },
);
