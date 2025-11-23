import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

enum PulseNavItem { home, history, menu, appointments, pulseKey, profile }

class PulseBottomNavigation extends StatelessWidget {
  const PulseBottomNavigation({
    super.key,
    required this.activeItem,
  });

  final PulseNavItem activeItem;

  bool _isActive(PulseNavItem item) => activeItem == item;

  void _handleTap(PulseNavItem item) {
    if (item == activeItem) {
      return;
    }

    switch (item) {
      case PulseNavItem.home:
        Get.offAllNamed('/home');
        break;
      case PulseNavItem.history:
        Get.toNamed('/history-selection');
        break;
      case PulseNavItem.menu:
        Get.toNamed('/menu');
        break;
      case PulseNavItem.appointments:
        Get.offAllNamed('/upcoming-appointments');
        break;
      case PulseNavItem.pulseKey:
        Get.toNamed('/pulse-key');
        break;
      case PulseNavItem.profile:
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    double resolvedBottomPadding = bottomInset > 0 ? bottomInset : 12.0;
    resolvedBottomPadding = resolvedBottomPadding.clamp(8.0, 24.0);

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: resolvedBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PulseNavItem.values.map((item) {
          return Expanded(
            child: _PulseBottomNavItem(
              icon: _iconFor(item),
              label: _labelFor(item),
              isActive: _isActive(item),
              onTap: () => _handleTap(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(PulseNavItem item) {
    switch (item) {
      case PulseNavItem.home:
        return Icons.home;
      case PulseNavItem.history:
        return Icons.grid_view;
      case PulseNavItem.menu:
        return Icons.add;
      case PulseNavItem.appointments:
        return Icons.calendar_today;
      case PulseNavItem.pulseKey:
        return Icons.vpn_key;
      case PulseNavItem.profile:
        return Icons.person;
    }
  }

  String _labelFor(PulseNavItem item) {
    switch (item) {
      case PulseNavItem.home:
        return 'Início';
      case PulseNavItem.history:
        return 'Históricos';
      case PulseNavItem.menu:
        return 'Registro';
      case PulseNavItem.appointments:
        return 'Consultas';
      case PulseNavItem.pulseKey:
        return 'Pulse Key';
      case PulseNavItem.profile:
        return 'Perfil';
    }
  }
}

class _PulseBottomNavItem extends StatelessWidget {
  const _PulseBottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              size: isActive ? 22 : 20,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

