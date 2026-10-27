class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://6ae04ff4be3bc8fead96dfd7.mockapi.io/api/v1';

  static const String visitors = '/visitors';
  static const String getAllVisitors = visitors;
  static const String createVisitor = visitors;

  static String visitorById(String id) => '$visitors/$id';
  static String updateVisitor(String id) => visitorById(id);
  static String patchVisitor(String id) => visitorById(id);
  static String deleteVisitor(String id) => visitorById(id);
}
