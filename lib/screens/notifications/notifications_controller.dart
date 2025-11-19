import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../routes/app_routes.dart';
import '../home/home_controller.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final bool isArchived;
  final String? type;
  final String? link;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    this.isArchived = false,
    this.type,
    this.link,
  });
}

class NotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  List<NotificationItem> get filteredNotifications {
    switch (filter.value) {
      case 'unread':
        return notifications.where((n) => !n.isRead && !n.isArchived).toList();
      case 'archived':
        return notifications.where((n) => n.isArchived).toList();
      default:
        return notifications.where((n) => !n.isArchived).toList();
    }
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    
    try {
      final apiService = ApiService();
      final notificacoesData = await apiService.buscarNotificacoes();
      
      final notificationsList = <NotificationItem>[];
      
      for (final notif in notificacoesData) {
        try {
          String id = '';
          if (notif['_id'] != null) {
            if (notif['_id'] is String) {
              id = notif['_id'];
            } else if (notif['_id'] is Map) {
              id = notif['_id']['\$oid']?.toString() ?? 
                   notif['_id']['oid']?.toString() ?? 
                   notif['_id'].toString();
            } else {
              id = notif['_id'].toString();
            }
          }
          
          if (id.isEmpty) {
            continue;
          }
          
          final title = notif['title']?.toString() ?? 'Notificação';
          final description = notif['description']?.toString() ?? '';
          final unread = notif['unread'] == true || 
                        notif['unread'] == 'true' || 
                        notif['unread'] == 1 ||
                        notif['unread'] == '1';
          final archived = notif['archived'] == true || 
                          notif['archived'] == 'true' || 
                          notif['archived'] == 1 ||
                          notif['archived'] == '1';
          final type = notif['type']?.toString() ?? 'updates';
          final link = notif['link']?.toString();
          
          DateTime date;
          if (notif['createdAt'] != null) {
            if (notif['createdAt'] is String) {
              try {
                date = DateTime.parse(notif['createdAt']);
              } catch (_) {
                date = DateTime.now();
              }
            } else if (notif['createdAt'] is Map) {
              if (notif['createdAt']?['\$date'] != null) {
                try {
                  final dateStr = notif['createdAt']['\$date'].toString();
                  date = DateTime.parse(dateStr);
                } catch (_) {
                  date = DateTime.now();
                }
              } else if (notif['createdAt']?['date'] != null) {
                try {
                  final dateStr = notif['createdAt']['date'].toString();
                  date = DateTime.parse(dateStr);
                } catch (_) {
                  date = DateTime.now();
                }
              } else {
                date = DateTime.now();
              }
            } else {
              date = DateTime.now();
            }
          } else {
            date = DateTime.now();
          }
          
          notificationsList.add(NotificationItem(
            id: id,
            title: title,
            message: description,
            date: date,
            isRead: !unread,
            isArchived: archived,
            type: type,
            link: link,
          ));
        } catch (e) {
          continue;
        }
      }
      
      notifications.value = notificationsList;
      notifications.refresh();
      update();
    } catch (e) {
      notifications.value = [];
      notifications.refresh();
      update();
    } finally {
      isLoading.value = false;
    }
  }

  int get unreadCount {
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.marcarNotificacaoComoLida(notificationId);
      
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          date: notifications[index].date,
          isRead: true,
          isArchived: notifications[index].isArchived,
          type: notifications[index].type,
          link: notifications[index].link,
        );
        notifications.refresh();
        _updateHomeNotificationsCount();
      }
    } catch (e) {
    }
  }
  
  void _updateHomeNotificationsCount() {
    try {
      final homeController = Get.find<HomeController>();
      homeController.loadNotificationsCount();
    } catch (e) {
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final apiService = ApiService();
      await apiService.marcarTodasNotificacoesComoLidas();
      
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = NotificationItem(
            id: notifications[i].id,
            title: notifications[i].title,
            message: notifications[i].message,
            date: notifications[i].date,
            isRead: true,
            isArchived: notifications[i].isArchived,
            type: notifications[i].type,
            link: notifications[i].link,
          );
        }
      }
      notifications.refresh();
      _updateHomeNotificationsCount();
    } catch (e) {
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.excluirNotificacao(notificationId);
      
      notifications.removeWhere((n) => n.id == notificationId);
      notifications.refresh();
      _updateHomeNotificationsCount();
    } catch (e) {
    }
  }

  Future<void> archiveNotification(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.arquivarNotificacao(notificationId);
      
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          date: notifications[index].date,
          isRead: notifications[index].isRead,
          isArchived: true,
          type: notifications[index].type,
          link: notifications[index].link,
        );
        notifications.refresh();
      }
    } catch (e) {
    }
  }

  Future<void> unarchiveNotification(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.desarquivarNotificacao(notificationId);
      
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          date: notifications[index].date,
          isRead: notifications[index].isRead,
          isArchived: false,
          type: notifications[index].type,
          link: notifications[index].link,
        );
        notifications.refresh();
      }
    } catch (e) {
    }
  }

  void setFilter(String newFilter) {
    filter.value = newFilter;
    loadNotifications();
  }

  Future<void> clearAll() async {
    try {
      for (final notif in notifications) {
        await deleteNotification(notif.id);
      }
      notifications.clear();
      notifications.refresh();
    } catch (e) {
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void handleNotificationTap(NotificationItem notification) {
    markAsRead(notification.id);
    
    if (notification.type == 'appointment') {
      Get.toNamed(Routes.APPOINTMENT_SCHEDULER);
    } else if (notification.type == 'exam') {
      Get.toNamed(Routes.EXAME_LIST);
    } else if (notification.type == 'prescription') {
    } else if (notification.type == 'pulse_key') {
      Get.toNamed(Routes.PULSE_KEY);
    } else if (notification.type == 'profile_update') {
      Get.toNamed(Routes.PROFILE);
    }
  }
}

