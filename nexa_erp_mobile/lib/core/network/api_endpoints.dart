class ApiEndpoints {
  ApiEndpoints._();
  
  // static const String baseUrl = 'http://10.0.2.2:8085/api';
  static const String baseUrl = 'http://localhost:8085/api';


  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardWorkflow = '/dashboard/workflow-summary';

  // Notifications
  // Notifications
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static String markRead(int id) => '/notifications/$id/read';
  static const String markAllRead = '/notifications/read-all';
}