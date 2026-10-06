import 'package:dio/dio.dart';

class BlocErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map<String, dynamic>) {
              return errors.values.map((v) => (v as List).join(', ')).join('\n');
            }
          }
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Превышено время ожидания ответа сервера.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          if (code == 401) return 'Сессия завершена или неверные учетные данные.';
          if (code == 404) return 'Запрошенный ресурс не найден.';
          if (code == 409) return 'Конфликт: такая запись уже существует.';
          if (code != null && code >= 500) return 'Ошибка на стороне сервера ($code).';
          return 'Ошибка запроса: статус $code';
        case DioExceptionType.connectionError:
          return 'Не удалось установить соединение с сервером. Проверьте сеть или статус бэкенда.';
        case DioExceptionType.cancel:
          return 'Запрос был отменен.';
        default:
          return error.message ?? 'Произошла непредвиденная сетевая ошибка.';
      }
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return error?.toString() ?? 'Произошла неизвестная ошибка.';
  }
}
