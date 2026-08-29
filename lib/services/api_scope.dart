import 'package:flutter/widgets.dart';

import 'api_service.dart';

/// InheritedWidget exposing the [ApiService] to the widget tree. Screens look
/// the service up with [ApiScope.of], while tests wrap the app in a scope that
/// provides a fake implementation.
class ApiScope extends InheritedWidget {
  const ApiScope({super.key, required this.service, required super.child});

  final ApiService service;

  static ApiService of(BuildContext context) {
    // Use getInheritedWidgetOfExactType so lookup works even during initState.
    final scope = context.getInheritedWidgetOfExactType<ApiScope>();
    return scope?.service ?? HttpApiService();
  }

  @override
  bool updateShouldNotify(ApiScope oldWidget) => service != oldWidget.service;
}
