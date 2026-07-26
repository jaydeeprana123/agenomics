import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/patient_registration_controller.dart';

class PatientRegistrationView extends GetView<PatientRegistrationController> {
  const PatientRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.isEditMode.value;

    return AppShell(
      title: isEdit
          ? 'Edit Patient — Registry'
          : 'Patient Registration — New Record',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = Responsive.formColumns(context);

          return SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      title: isEdit ? 'Edit Patient' : 'Register New Patient',
                      subtitle: isEdit
                          ? 'Update fields allowed by PatientUpdate API.'
                          : 'Fields match PatientCreate API payload.',
                      actions: [
                        AppButton(
                          label: 'Back',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.arrow_back,
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PATIENT DETAILS',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ResponsiveFormGrid(
                            columns: columns,
                            children: [
                              AppTextField(
                                controller: controller.firstNameController,
                                label: 'First Name *',
                                hint: 'First name',
                                validator: (v) =>
                                    Validators.required(v, 'First name'),
                              ),
                              AppTextField(
                                controller: controller.lastNameController,
                                label: 'Last Name *',
                                hint: 'Last name',
                                validator: (v) =>
                                    Validators.required(v, 'Last name'),
                              ),
                              _GenderDropdown(
                                controller: controller,
                                readOnly: isEdit,
                              ),
                              Obx(
                                () => InkWell(
                                  onTap: () =>
                                      controller.pickDateOfBirth(context),
                                  borderRadius:
                                      BorderRadius.circular(AppColors.radius),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date of Birth *',
                                      suffixIcon: Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                      ),
                                    ),
                                    child: Text(
                                      controller.dobDisplay.isEmpty
                                          ? 'Select date'
                                          : controller.dobDisplay,
                                      style: TextStyle(
                                        fontFamily: 'Mulish',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: controller.dobDisplay.isEmpty
                                            ? AppColors.textTertiary
                                            : AppColors.text,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(() {
                                controller.dateOfBirth.value;
                                return AppTextField(
                                  controller: controller.ageController,
                                  label: 'Age (auto-calculated)',
                                  hint: 'Select date of birth',
                                  readOnly: true,
                                );
                              }),
                              AppTextField(
                                controller: controller.mobileController,
                                label: 'Mobile *',
                                hint: '+971...',
                                keyboardType: TextInputType.phone,
                                validator: Validators.mobile,
                              ),
                              AppTextField(
                                controller: controller.emailController,
                                label: 'Email',
                                hint: 'name@email.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                              ),
                              AppTextField(
                                controller: controller.emiratesIdController,
                                label: isEdit ? 'Emirates ID' : 'Emirates ID *',
                                hint: '784-XXXX-XXXXXXX-X',
                                readOnly: isEdit,
                                validator: isEdit ? null : Validators.emiratesId,
                              ),
                              AppTextField(
                                controller: controller.sourceController,
                                label: 'Source',
                                hint: 'manual',
                                readOnly: isEdit,
                              ),
                              AppTextField(
                                controller: controller.addressLineController,
                                label: 'Address Line',
                                hint: 'Street / area',
                              ),
                              AppTextField(
                                controller: controller.cityController,
                                label: 'City',
                                hint: 'City',
                              ),
                              AppTextField(
                                controller: controller.stateController,
                                label: 'State / Emirate',
                                hint: 'Emirate / State',
                              ),
                              AppTextField(
                                controller: controller.pincodeController,
                                label: 'Pincode',
                                hint: 'Postal code',
                                validator: Validators.pincode,
                              ),
                            ],
                          ),
                          if (isEdit) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius:
                                    BorderRadius.circular(AppColors.radius),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'Gender, Emirates ID, and source cannot be changed via the Update Patient API.',
                                style: TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AppButton(
                            label: 'Save',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.save_outlined,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.saveAndReturn,
                          ),
                          AppButton(
                            label: 'Continue',
                            icon: Icons.arrow_forward,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.saveAndContinue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final PatientRegistrationController controller;
  final bool readOnly;

  const _GenderDropdown({
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          readOnly ? 'Gender' : 'Gender *',
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: controller.gender.value,
          decoration: InputDecoration(
            hintText: 'Select gender',
            suffixIcon: readOnly
                ? const Icon(Icons.lock_outline, size: 16)
                : null,
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: readOnly
              ? null
              : (v) => controller.gender.value = v,
        ),
      ],
    );
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  final int columns;
  final List<Widget> children;

  const _ResponsiveFormGrid({
    required this.columns,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        children: [
          for (final child in children) ...[
            child,
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
