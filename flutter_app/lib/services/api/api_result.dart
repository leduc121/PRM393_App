class ApiResult {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;

  ApiResult._({required this.isSuccess, this.data, this.errorMessage});

  factory ApiResult.success(dynamic data) =>
      ApiResult._(isSuccess: true, data: data);

  factory ApiResult.error(String message) =>
      ApiResult._(isSuccess: false, errorMessage: message);
}
