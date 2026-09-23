import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/local_data_service.dart';

class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalDataService.instance,
      builder: (context, _) {
        final currentRole = LocalDataService.instance.currentRole;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoleTab(
                context,
                role: UserRole.patient,
                label: 'Patient',
                icon: Icons.person_outline_rounded,
                isSelected: currentRole == UserRole.patient,
              ),
              const SizedBox(width: 4),
              _buildRoleTab(
                context,
                role: UserRole.caregiver,
                label: 'Caregiver',
                icon: Icons.favorite_outline_rounded,
                isSelected: currentRole == UserRole.caregiver,
              ),
              const SizedBox(width: 4),
              _buildRoleTab(
                context,
                role: UserRole.doctor,
                label: 'Doctor',
                icon: Icons.medical_services_outlined,
                isSelected: currentRole == UserRole.doctor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTab(
    BuildContext context, {
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => LocalDataService.instance.setRole(role),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
