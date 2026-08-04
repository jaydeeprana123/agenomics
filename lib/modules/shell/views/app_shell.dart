import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_logo_mark.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../patient_list/controllers/patient_list_controller.dart';
import '../controllers/selected_encounter_controller.dart';
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
              backgroundColor: AppColors.night2,
              width: 250,
              child: SafeArea(child: _SidebarContent(controller: shell)),
            ),
      body: Row(
        children: [
          if (showSidebar)
            SizedBox(
              width: 250,
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

  void _openPatientList() {
    if (Get.currentRoute == AppRoutes.patientList) return;
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.patientList || route.isFirst,
    );
    if (Get.currentRoute != AppRoutes.patientList) {
      Get.offAllNamed(AppRoutes.patientList);
    }
  }

  void _openEncounters() {
    final selected = Get.find<SelectedPatientController>().selected.value;
    if (selected == null || selected.id.isEmpty) {
      Get.snackbar(
        'Select a patient',
        'Choose a patient from the Patient List first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: AppColors.text,
      );
      _openPatientList();
      return;
    }
    if (Get.currentRoute == AppRoutes.encounters) return;
    Get.toNamed(AppRoutes.encounters);
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthRepository>().getCurrentUser();
    final selectedPatient = Get.find<SelectedPatientController>();
    final selectedEncounter = Get.find<SelectedEncounterController>();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(() {
            final patient = selectedPatient.selected.value;
            final encounter = selectedEncounter.selected.value;

            if (patient == null) {
              return InkWell(
                onTap: _openPatientList,
                borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                    border: Border.all(color: AppColors.borderStrong),
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
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _openPatientList,
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.brand600,
                      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                      border: Border.all(color: AppColors.brand600),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            patient.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          patient.uhid,
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _openEncounters,
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: encounter == null
                          ? AppColors.surface
                          : AppColors.infoBg,
                      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                      border: Border.all(
                        color: encounter == null
                            ? AppColors.borderStrong
                            : AppColors.infoRing,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 14,
                          color: encounter == null
                              ? AppColors.textSecondary
                              : AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            encounter == null
                                ? 'Select visit'
                                : encounter.displayLabel,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: encounter == null
                                  ? AppColors.textSecondary
                                  : AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(width: 8),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Text(
                user.name,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              border: Border.all(color: AppColors.successRing),
            ),
            child: const Text(
              '● Live',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 10,
                fontWeight: FontWeight.w600,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.night2, AppColors.side2],
        ),
        border: Border(right: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppLogoMark(size: 32, onDark: true),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AGenomics',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkInk,
                              letterSpacing: -0.2,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'CLINICAL INTELLIGENCE',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 9.5,
                              color: AppColors.darkText3,
                              letterSpacing: 0.16 * 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 14),
              children: [
                const _NavSection('Platform'),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Patients',
                  route: AppRoutes.patientList,
                  isActive: Get.currentRoute == AppRoutes.patientList,
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
                    if (Get.currentRoute != AppRoutes.patientList) {
                      Get.offAllNamed(AppRoutes.patientList);
                    }
                  },
                ),
                const _NavSection('Workflow'),
                _NavItem(
                  icon: Icons.event_note_outlined,
                  label: 'Encounters',
                  route: AppRoutes.encounters,
                  isActive: Get.currentRoute == AppRoutes.encounters,
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
                    if (Get.currentRoute == AppRoutes.encounters) return;
                    Get.toNamed(AppRoutes.encounters);
                  },
                ),
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
                  icon: Icons.biotech_outlined,
                  label: 'Genomic Analysis',
                  route: AppRoutes.genomicsAnalysis,
                  isActive: Get.currentRoute == AppRoutes.genomicsAnalysis,
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
                    if (Get.currentRoute == AppRoutes.genomicsAnalysis) return;
                    Get.toNamed(AppRoutes.genomicsAnalysis);
                  },
                ),
                _NavItem(
                  icon: Icons.medication_outlined,
                  label: 'Medicines',
                  route: AppRoutes.medicines,
                  isActive: Get.currentRoute == AppRoutes.medicines,
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    if (Get.currentRoute == AppRoutes.medicines) return;
                    Get.toNamed(AppRoutes.medicines);
                  },
                ),
                _NavItem(
                  icon: Icons.science_outlined,
                  label: 'VCF File Run',
                  route: AppRoutes.vcfFileRun,
                  isActive: Get.currentRoute == AppRoutes.vcfFileRun,
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                    if (Get.currentRoute == AppRoutes.vcfFileRun) return;
                    Get.toNamed(AppRoutes.vcfFileRun);
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
          const Divider(height: 1, color: AppColors.darkBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                    } else if (Get.isRegistered<SelectedEncounterController>()) {
                      await Get.find<SelectedEncounterController>().clear();
                    }
                    await Get.find<AuthRepository>().logout();
                    if (Get.isRegistered<PatientListController>()) {
                      Get.delete<PatientListController>(force: true);
                    }
                    Get.offAllNamed(AppRoutes.login);
                  },
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 14, color: AppColors.darkText4),
                        SizedBox(width: 8),
                        Text(
                          'Sign out',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'POC v7.3 · Clinical Intelligence',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 10,
                    color: AppColors.darkText4,
                    height: 1.5,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 5),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15 * 9.5,
          color: AppColors.darkText4,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.035),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.brand400.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  )
                : null,
            border: Border(
              left: BorderSide(
                width: 2,
                color: isActive ? AppColors.brand400 : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.brand400 : AppColors.darkText2,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.brand400 : AppColors.darkText2,
                  ),
                ),
              ),
            ],
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
    final color = ok ? AppColors.brand400 : const Color(0xFFF45B69);

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
              color: AppColors.darkText4,
            ),
          ),
        ],
      ),
    );
  }
}
