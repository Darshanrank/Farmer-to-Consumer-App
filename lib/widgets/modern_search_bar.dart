import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class ModernSearchBar extends StatelessWidget {
  final String hint;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;
  final TextEditingController? controller;

  const ModernSearchBar({
    super.key,
    this.hint = "Search farming inputs...",
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
