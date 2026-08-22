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


  // Accounts
  static const String accounts = '/accounts';
  static const String accountsTree = '/accounts/tree';
  static const String accountsSearch = '/accounts/search';
  static String accountById(int id) => '/accounts/$id';
  static String accountByType(String type) => '/accounts/type/$type';
  static String accountDeactivate(int id) => '/accounts/$id/deactivate';
  static String accountActivate(int id) => '/accounts/$id/activate';

  // Journal Entries
  static const String journals = '/journals';
  static String journalById(int id) => '/journals/$id';
  static String journalPost(int id) => '/journals/$id/post';
  static String journalSubmitApproval(int id) => '/journals/$id/submit-approval';
  static String journalReverse(int id) => '/journals/$id/reverse';

  // Approvals
  static const String approvalsPending = '/approvals/pending';
  static const String approvalsPendingCount = '/approvals/pending/count';
  static const String approvalsMyRequests = '/approvals/my-requests';
  static const String approvalsMyActions = '/approvals/my-actions';
  static String approvalById(int id) => '/approvals/$id';
  static String approvalApprove(int id) => '/approvals/$id/approve';
  static String approvalReject(int id) => '/approvals/$id/reject';
  static String approvalReturn(int id) => '/approvals/$id/return';
}