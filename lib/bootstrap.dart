import 'package:domify_tool/core/error/app_bloc_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Prepares everything the app needs before the first frame.
///
/// Kept apart from `main` so that future flavors (development, staging,
/// production) share one startup path and differ only in what they inject.
Future<void> bootstrap() async {
  // Required because we touch platform channels before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();
}
