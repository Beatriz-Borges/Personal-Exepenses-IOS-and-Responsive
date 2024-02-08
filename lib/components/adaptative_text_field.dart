import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AdaptativeTextField extends StatelessWidget {
  final TextEditingController? controller;

  final TextInputType keyboardType;

  final String? label;
  final Function(String)? onSumitted;

  const AdaptativeTextField({
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onSumitted,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: keyboardType,
              onSubmitted: onSumitted,
              placeholder: label,
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 12,
              ),
            ),
          )
        : TextField(
            controller: controller,
            keyboardType: keyboardType,
            onSubmitted: (_) => onSumitted,
            decoration: InputDecoration(
              labelText: label,
            ),
          );
  }
}
