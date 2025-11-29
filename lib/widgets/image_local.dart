import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Widget imageLocal(String filename) {
  return FutureBuilder(
    future: getApplicationDocumentsDirectory(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      final path = "${snapshot.data!.path}/$filename";
      return Image.file(File(path));
    },
  );
}
