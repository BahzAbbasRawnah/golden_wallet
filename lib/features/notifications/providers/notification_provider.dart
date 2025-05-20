import 'package:flutter/material.dart';
import 'package:golden_wallet/features/notifications/models/notification_model.dart';

/// Provider to manage notifications
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  /// Get all notifications
  List<NotificationModel> get notifications => _notifications;
  
  /// Get unread notifications
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((notification) => !notification.isRead).toList();
  
  /// Get the number of unread notifications
  int get unreadCount => unreadNotifications.length;
  
  /// Check if notifications are loading
  bool get isLoading => _isLoading;
  
  /// Get the error message
  String? get error => _error;
  
  /// Fetch notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock notifications data
      _notifications = _generateMockNotifications();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index == -1) return;
    
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    
    // Simulate API call
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, you would make an API call to update the notification status
    } catch (e) {
      // If the API call fails, revert the change
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.where((notification) => !notification.isRead).toList();
    if (unreadNotifications.isEmpty) return;
    
    // Update local state
    _notifications = _notifications.map((notification) => 
        notification.copyWith(isRead: true)).toList();
    notifyListeners();
    
    // Simulate API call
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, you would make an API call to update all notifications
    } catch (e) {
      // If the API call fails, revert the change
      _notifications = _notifications.map((notification) {
        final wasUnread = unreadNotifications.any((n) => n.id == notification.id);
        return wasUnread ? notification.copyWith(isRead: false) : notification;
      }).toList();
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index == -1) return;
    
    final deletedNotification = _notifications[index];
    _notifications.removeAt(index);
    notifyListeners();
    
    // Simulate API call
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, you would make an API call to delete the notification
    } catch (e) {
      // If the API call fails, revert the change
      _notifications.insert(index, deletedNotification);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_notifications.isEmpty) return;
    
    final oldNotifications = List<NotificationModel>.from(_notifications);
    _notifications = [];
    notifyListeners();
    
    // Simulate API call
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, you would make an API call to delete all notifications
    } catch (e) {
      // If the API call fails, revert the change
      _notifications = oldNotifications;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }
  
  /// Get notifications by date range
  List<NotificationModel> getNotificationsByDateRange(DateTime startDate, DateTime endDate) {
    return _notifications.where((notification) => 
        notification.createdAt.isAfter(startDate) && 
        notification.createdAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
  }
  
  /// Generate mock notifications for testing
  List<NotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    
    return [
      NotificationModel(
        id: '1',
        title: 'Gold Price Alert',
        message: 'Gold price has increased by 2.5% in the last 24 hours.',
        type: NotificationType.priceAlert,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        data: {
          'price': 1850.75,
          'change': 2.5,
          'currency': 'USD',
        },
      ),
      NotificationModel(
        id: '2',
        title: 'Transaction Completed',
        message: 'Your purchase of 1.5 oz of gold has been completed successfully.',
        type: NotificationType.transaction,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
        data: {
          'transactionId': 'TX123456',
          'amount': 1.5,
          'unit': 'oz',
          'price': 2775.50,
          'currency': 'USD',
        },
      ),
      NotificationModel(
        id: '3',
        title: 'System Maintenance',
        message: 'The app will be under maintenance on June 15, 2023, from 2:00 AM to 4:00 AM UTC.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        title: 'Special Offer',
        message: 'Get 0.5% discount on gold purchases above 5 oz until the end of the month.',
        type: NotificationType.promotion,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: false,
        data: {
          'discountRate': 0.5,
          'minAmount': 5,
          'unit': 'oz',
          'validUntil': DateTime(now.year, now.month + 1, 1).toIso8601String(),
        },
      ),
      NotificationModel(
        id: '5',
        title: 'Transaction Pending',
        message: 'Your withdrawal of \$1,200 is pending approval.',
        type: NotificationType.transaction,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        data: {
          'transactionId': 'TX789012',
          'amount': 1200,
          'currency': 'USD',
          'status': 'pending',
        },
      ),
      NotificationModel(
        id: '6',
        title: 'Gold Price Alert',
        message: 'Gold price has decreased by 1.2% in the last 24 hours.',
        type: NotificationType.priceAlert,
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        data: {
          'price': 1820.30,
          'change': -1.2,
          'currency': 'USD',
        },
      ),
      NotificationModel(
        id: '7',
        title: 'Account Security',
        message: 'Your account password was changed successfully.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
      NotificationModel(
        id: '8',
        title: 'Weekend Promotion',
        message: 'Enjoy zero transaction fees this weekend on all gold purchases.',
        type: NotificationType.promotion,
        createdAt: now.subtract(const Duration(days: 6)),
        isRead: false,
        data: {
          'startDate': DateTime(now.year, now.month, now.day - 6).toIso8601String(),
          'endDate': DateTime(now.year, now.month, now.day - 4).toIso8601String(),
        },
      ),
    ];
  }
}
