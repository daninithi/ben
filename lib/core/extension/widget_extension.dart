import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  showSnackBar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(text)
      )
    );
  }

}