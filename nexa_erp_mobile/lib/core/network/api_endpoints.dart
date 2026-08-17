class ApiEndpoints {
  ApiEndpoints._();
  
  static const String baseUrl = 'http://10.0.2.2:8085/api';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardWorkflow = '/dashboard/workflow-summary';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
}