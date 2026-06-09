class ApiConstants {
  static const String baseUrl = 'https://rentra-backend-z36t.onrender.com';

  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String tenantLogin = '$baseUrl/auth/tenant-login';
  static const String generatePasskey = '$baseUrl/auth/generate-passkey';
  static const String onboardTenant = '$baseUrl/auth/onboard-tenant';

  // Organization endpoints
  static String organization(String orgId) => '$baseUrl/organizations/$orgId';

  // Building endpoints
  static String buildings(String orgId) =>
      '$baseUrl/organizations/$orgId/buildings';
  static String building(String orgId, String buildingId) =>
      '$baseUrl/organizations/$orgId/buildings/$buildingId';

  // Room endpoints
  static String rooms(String orgId, String buildingId) =>
      '$baseUrl/organizations/$orgId/buildings/$buildingId/rooms';
  static String room(String orgId, String buildingId, String roomId) =>
      '$baseUrl/organizations/$orgId/buildings/$buildingId/rooms/$roomId';
  static String vacantRooms(String orgId, String buildingId) =>
      '$baseUrl/organizations/$orgId/buildings/$buildingId/rooms/vacant';

  // Tenant endpoints
  static String tenants(String orgId) =>
      '$baseUrl/organizations/$orgId/tenants';
  static String tenant(String orgId, String tenantId) =>
      '$baseUrl/organizations/$orgId/tenants/$tenantId';

  // Payment endpoints
  static String payments(String orgId) =>
      '$baseUrl/organizations/$orgId/payments';
  static String paymentStats(String orgId, int month, int year) =>
      '$baseUrl/organizations/$orgId/payments/stats?month=$month&year=$year';
  static String paymentArrears(String orgId) =>
      '$baseUrl/organizations/$orgId/payments/arrears';

  // Maintenance endpoints
  static String maintenance(String orgId) =>
      '$baseUrl/organizations/$orgId/maintenance';

  // Dashboard endpoints
  static String dashboardOverview(String orgId) =>
      '$baseUrl/organizations/$orgId/dashboard/overview';
  static String dashboardFinancial(String orgId, int month, int year) =>
      '$baseUrl/organizations/$orgId/dashboard/financial?month=$month&year=$year';
  static String dashboardBuildings(String orgId) =>
      '$baseUrl/organizations/$orgId/dashboard/buildings';
}