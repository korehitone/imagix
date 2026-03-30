import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final double width;
  final double height;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.width = 331,
    this.height = 44,
    this.maxLines = 1,
  });

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: maxLines > 1 ? null : height, // avoid clipping multiline fields
      child: TextField(
        controller: controller,
        obscureText: maxLines > 1 ? false : obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          enabledBorder: _border(),
          focusedBorder: _border(),
        ),
      ),
    );
  }
}