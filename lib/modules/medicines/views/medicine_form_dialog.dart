import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/medicine_model.dart';
import '../controllers/medicines_controller.dart';

class MedicineFormDialog extends StatefulWidget {
  final MedicineModel? medicine;
  final Future<bool> Function(String name, bool requiresOncologyCheck) onSubmit;

  const MedicineFormDialog({
    super.key,
    this.medicine,
    required this.onSubmit,
  });

  bool get isEditing => medicine != null;

  @override
  State<MedicineFormDialog> createState() => _MedicineFormDialogState();
}

class _MedicineFormDialogState extends State<MedicineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late bool _requiresOncologyCheck;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _requiresOncologyCheck = widget.medicine?.requiresOncologyCheck ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(
      _nameController.text.trim(),
      _requiresOncologyCheck,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicinesController>();

    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit medicine' : 'Add medicine',
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Medicine name',
                hint: 'e.g. Tamoxifen',
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Medicine name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Enter at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Requires oncology check',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  subtitle: const Text(
                    'Flag agents that need companion-diagnostic review.',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _requiresOncologyCheck,
                  activeTrackColor: AppColors.primary,
                  onChanged: _submitting
                      ? null
                      : (value) =>
                          setState(() => _requiresOncologyCheck = value),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        Obx(() {
          final busy = _submitting || controller.isSaving.value;
          return AppButton(
            label: widget.isEditing ? 'Save changes' : 'Create',
            icon: widget.isEditing ? Icons.save_outlined : Icons.add,
            isLoading: busy,
            onPressed: busy ? null : _submit,
          );
        }),
      ],
    );
  }
}
