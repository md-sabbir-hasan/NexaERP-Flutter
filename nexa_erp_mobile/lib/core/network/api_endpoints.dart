class ApiEndpoints {
  ApiEndpoints._();
  
   //static const String baseUrl = 'http://10.0.2.2:8085/api';
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


  // Users
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static String userDeactivate(int id) => '/users/$id/deactivate';
  static String userActivate(int id) => '/users/$id/activate';

  // Roles
  static const String roles = '/roles';
  static String roleById(int id) => '/roles/$id';
  static String roleAssignPermissions(int id) => '/roles/$id/permissions/assign';
  static String roleRemovePermissions(int id) => '/roles/$id/permissions/remove';

  // Permissions
  static const String permissions = '/permissions';


  // Parties (light usage — picker only)
  static const String parties = '/parties';
  static String partiesByType(String type) => '/parties/type/$type';


  // Expenses
  static const String expenses = '/expenses';
  static String expenseById(int id) => '/expenses/$id';
  static String expensePost(int id) => '/expenses/$id/post';
  static String expenseCancel(int id) => '/expenses/$id/cancel';


  // Invoices
  static const String invoices = '/invoices';
  static String invoiceById(int id) => '/invoices/$id';
  static String invoicePost(int id) => '/invoices/$id/post';
  static String invoiceCancel(int id) => '/invoices/$id/cancel';
  static String invoiceSubmitApproval(int id) => '/invoices/$id/submit-approval';

  // Vendor Bills
  static const String vendorBills = '/vendor-bills';
  static String vendorBillById(int id) => '/vendor-bills/$id';
  static String vendorBillApprove(int id) => '/vendor-bills/$id/approve';
  static String vendorBillSubmitApproval(int id) => '/vendor-bills/$id/submit-approval';
  static String vendorBillPost(int id) => '/vendor-bills/$id/post';
  static String vendorBillCancel(int id) => '/vendor-bills/$id/cancel';


  // Payments
  static const String payments = '/payments';
  static String paymentById(int id) => '/payments/$id';
  static String paymentByParty(int partyId) => '/payments/party/$partyId';
  static const String paymentOutstandingSummary = '/payments/outstanding-summary';
  static String paymentPost(int id) => '/payments/$id/post';
  static String paymentSubmitApproval(int id) => '/payments/$id/submit-approval';
  static String paymentCancel(int id) => '/payments/$id/cancel';


  // Credit Notes
  static const String creditNotes = '/credit-notes';
  static String creditNoteById(int id) => '/credit-notes/$id';
  static String creditNoteApprove(int id) => '/credit-notes/$id/approve';
  static String creditNotePost(int id) => '/credit-notes/$id/post';
  static String creditNoteCancel(int id) => '/credit-notes/$id/cancel';

  // Debit Notes
  static const String debitNotes = '/debit-notes';
  static String debitNoteById(int id) => '/debit-notes/$id';
  static String debitNoteApprove(int id) => '/debit-notes/$id/approve';
  static String debitNotePost(int id) => '/debit-notes/$id/post';
  static String debitNoteCancel(int id) => '/debit-notes/$id/cancel';


  // Banking
  static const String bankAccounts = '/bank-accounts';
  static String bankAccountById(int id) => '/bank-accounts/$id';
  static String bankAccountDeactivate(int id) => '/bank-accounts/$id/deactivate';
  static String bankAccountActivate(int id) => '/bank-accounts/$id/activate';

  static const String bankTransactions = '/bank-transactions';
  static String bankTransactionsByAccount(int accountId) => '/bank-transactions/account/$accountId';
  static String bankTransactionReconcile(int id) => '/bank-transactions/$id/reconcile';
  static String bankTransactionUnreconcile(int id) => '/bank-transactions/$id/unreconcile';
  static String bankTransactionVoid(int id) => '/bank-transactions/$id/void';
  static const String bankTransfer = '/bank-transactions/transfer';
}