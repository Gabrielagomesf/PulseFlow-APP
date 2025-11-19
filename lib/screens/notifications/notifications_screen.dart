import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../screens/home/home_controller.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.blueSystemOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFF00324A),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(controller),
              _buildFilterTabs(controller),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00324A)),
                        ),
                      );
                    }

                    final filtered = controller.filteredNotifications;

                    if (filtered.isEmpty) {
                      return _buildEmptyState(controller);
                    }

                    return Column(
                      children: [
                        if (controller.filter.value == 'all' && controller.unreadCount > 0)
                          _buildMarkAllReadButton(controller),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await controller.loadNotifications();
                              try {
                                final homeController = Get.find<HomeController>();
                                await homeController.loadNotificationsCount();
                              } catch (e) {}
                            },
                            color: const Color(0xFF00324A),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final notification = filtered[index];
                                return _buildNotificationCard(controller, notification);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF00324A),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.unreadCount > 0
                      ? '${controller.unreadCount} não lida${controller.unreadCount > 1 ? 's' : ''}'
                      : 'Todas lidas',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF00324A),
      child: Row(
        children: [
          _buildFilterTab(controller, 'all', 'Todas', Icons.notifications_outlined),
          const SizedBox(width: 8),
          _buildFilterTab(controller, 'unread', 'Não lidas', Icons.mark_email_unread_outlined),
          const SizedBox(width: 8),
          _buildFilterTab(controller, 'archived', 'Arquivadas', Icons.archive_outlined),
        ],
      ),
    );
  }

  Widget _buildFilterTab(NotificationsController controller, String value, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.filter.value == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.setFilter(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? const Color(0xFF00324A) : Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF00324A) : Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMarkAllReadButton(NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => controller.markAllAsRead(),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Marcar todas como lidas'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00324A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationsController controller,
    NotificationItem notification,
  ) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.archive_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          controller.archiveNotification(notification.id);
          Get.snackbar(
            'Arquivado',
            'Notificação arquivada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        } else {
          _showDeleteDialog(controller, notification);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmDialog(controller, notification);
        }
        return true;
      },
      child: InkWell(
        onTap: () => controller.handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread
                ? const Color(0xFF00324A).withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? const Color(0xFF00324A).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTheme.titleSmall.copyWith(
                              color: const Color(0xFF1E293B),
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00324A),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formatDate(notification.date),
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: notification.isArchived ? 'unarchive' : 'archive',
                              child: Row(
                                children: [
                                  Icon(
                                    notification.isArchived ? Icons.unarchive : Icons.archive,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(notification.isArchived ? 'Desarquivar' : 'Arquivar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'archive') {
                              controller.archiveNotification(notification.id);
                            } else if (value == 'unarchive') {
                              controller.unarchiveNotification(notification.id);
                            } else if (value == 'delete') {
                              _showDeleteDialog(controller, notification);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(NotificationsController controller) {
    String message;
    IconData icon;
    
    switch (controller.filter.value) {
      case 'unread':
        message = 'Você não possui notificações não lidas';
        icon = Icons.mark_email_read_outlined;
        break;
      case 'archived':
        message = 'Você não possui notificações arquivadas';
        icon = Icons.archive_outlined;
        break;
      default:
        message = 'Você não possui notificações no momento';
        icon = Icons.notifications_none_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF00324A).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 72,
                color: const Color(0xFF00324A).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTheme.titleMedium.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Novas notificações aparecerão aqui',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'exam':
        return Icons.assignment_rounded;
      case 'prescription':
        return Icons.medication_rounded;
      case 'pulse_key':
        return Icons.vpn_key_rounded;
      case 'profile_update':
        return Icons.person_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'appointment':
        return const Color(0xFF00324A);
      case 'reminder':
        return Colors.orange;
      case 'exam':
        return Colors.blue;
      case 'prescription':
        return Colors.green;
      case 'pulse_key':
        return Colors.purple;
      case 'profile_update':
        return Colors.teal;
      default:
        return const Color(0xFF00324A);
    }
  }

  Future<bool> _showDeleteConfirmDialog(NotificationsController controller, NotificationItem notification) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Excluir notificação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Deseja realmente excluir esta notificação?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showDeleteDialog(NotificationsController controller, NotificationItem notification) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Excluir notificação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Deseja realmente excluir esta notificação?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteNotification(notification.id);
              Get.back();
              Get.snackbar(
                'Excluído',
                'Notificação excluída',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
