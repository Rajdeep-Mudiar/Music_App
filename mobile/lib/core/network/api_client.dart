import 'package:dio/dio.dart';
import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storageService;

  ApiClient({required this.storageService}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await storageService.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Attempt token refresh
                final refreshDio =
                    Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                final res = await refreshDio.post(
                  ApiConstants.authRefresh,
                  data: {'refresh_token': refreshToken},
                );
                if (res.statusCode == 200) {
                  final newAccessToken = res.data['access_token'];
                  final newRefreshToken = res.data['refresh_token'];
                  await storageService.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  // Retry original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final retryRes = await dio.fetch(retryOptions);
                  return handler.resolve(retryRes);
                }
              } catch (_) {
                await storageService.clearTokens();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
