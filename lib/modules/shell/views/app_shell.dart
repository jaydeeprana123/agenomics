import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../patient_list/controllers/patient_list_controller.dart';
import '../controllers/selected_patient_controller.dart';
import '../controllers/shell_controller.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;

  const AppShell({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(ShellController(), permanent: true);
    shell.setTitle(title);

    final showSidebar = Responsive.showSidebar(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: AppColors.sidebar,
              width: 210,
              child: SafeArea(child: _SidebarContent(controller: shell)),
            ),
      body: Row(
        children: [
          if (showSidebar)
            SizedBox(
              width: 210,
              child: _SidebarContent(controller: shell),
            ),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title, showMenu: !showSidebar),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.background,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool showMenu;

  const _TopBar({required this.title, required this.showMenu});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthRepository>().getCurrentUser();
    final selectedPatient = Get.find<SelectedPatientController>();

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, size: 20),
              color: AppColors.text,
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.slate,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(() {
            final patient = selectedPatient.selected.value;
            if (patient == null) {
              return InkWell(
                onTap: () {
                  if (Get.currentRoute != AppRoutes.patientList) {
                    Get.until(
                      (route) =>
                          route.settings.name == AppRoutes.patientList ||
                          route.isFirst,
                    );
                    if (Get.currentRoute != AppRoutes.patientList) {
                      Get.offAllNamed(AppRoutes.patientList);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search_outlined,
                          size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'Select patient',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return InkWell(
              onTap: () {
                if (Get.currentRoute == AppRoutes.patientList) return;
                Get.until(
                  (route) =>
                      route.settings.name == AppRoutes.patientList ||
                      route.isFirst,
                );
                if (Get.currentRoute != AppRoutes.patientList) {
                  Get.offAllNamed(AppRoutes.patientList);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryMid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        patient.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      patient.uhid,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                user.name,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.successRing),
            ),
            child: const Text(
              '● Live',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final ShellController controller;

  const _SidebarContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: 'A'),
                      TextSpan(
                        text: 'Genomics',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'CLAIM CHECKER · UAE',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 9,
                    color: Color(0x4DFFFFFF),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x2E16A07A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x4D16A07A)),
                  ),
                  child: const Text(
                    '● LIVE · Edge v3.0',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x12FFFFFF)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              children: [
                const _NavSection('Overview'),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Patients',
                  route: AppRoutes.patientList,
                  isActive: Get.currentRoute.startsWith('/patients') &&
                      !Get.currentRoute.contains('register') &&
                      !Get.currentRoute.contains('documents') &&
                      !Get.currentRoute.contains('edit'),
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    if (Get.currentRoute == AppRoutes.patientList) return;
                    Get.until(
                      (route) =>
                          route.settings.name == AppRoutes.patientList ||
                          route.isFirst,
                    );
                  },
                ),
                const _NavSection('Workflow'),
                _NavItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Physician / HIS',
                  route: AppRoutes.physicianHis,
                  isActive: Get.currentRoute == AppRoutes.physicianHis,
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    final selected =
                        Get.find<SelectedPatientController>().selected.value;
                    if (selected == null || selected.id.isEmpty) {
                      Get.snackbar(
                        'Select a patient',
                        'Choose a patient from the Patient List first.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.surface,
                        colorText: AppColors.text,
                      );
                      return;
                    }
                    if (Get.currentRoute == AppRoutes.physicianHis) return;
                    Get.toNamed(AppRoutes.physicianHis);
                  },
                ),
                _NavItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'New Patient',
                  route: AppRoutes.patientRegistration,
                  isActive: Get.currentRoute.contains('register') ||
                      Get.currentRoute.contains('edit'),
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    Get.toNamed(AppRoutes.patientRegistration);
                  },
                ),
                _NavItem(
                  icon: Icons.upload_file_outlined,
                  label: 'Upload Docs',
                  route: AppRoutes.uploadDocuments,
                  isActive: Get.currentRoute.contains('documents'),
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    Get.snackbar(
                      'Select a patient',
                      'Use Continue on a patient row to upload documents.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.surface,
                      colorText: AppColors.text,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x0FFFFFFF)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StatusRow(label: 'Claim Engine', ok: true),
                const _StatusRow(label: 'Document Store', ok: true),
                const _StatusRow(label: 'API', ok: true),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    if (Get.isRegistered<SelectedPatientController>()) {
                      await Get.find<SelectedPatientController>().clear();
                    }
                    await Get.find<AuthRepository>().logout();
                    if (Get.isRegistered<PatientListController>()) {
                      Get.delete<PatientListController>(force: true);
                    }
                    Get.offAllNamed(AppRoutes.login);
                  },
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 14, color: Color(0x59FFFFFF)),
                        SizedBox(width: 8),
                        Text(
                          'Sign out',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0x59FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  final String label;
  const _NavSection(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: Color(0x38FFFFFF),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.radius),
          hoverColor: const Color(0x2416A07A),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive ? Colors.white : const Color(0x8CFFFFFF),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0x8CFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ok;

  const _StatusRow({
    required this.label,
    this.ok = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.accent : const Color(0xFFF87171);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 10,
              color: Color(0x59FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
