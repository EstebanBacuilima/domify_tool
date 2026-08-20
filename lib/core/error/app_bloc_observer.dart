import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Single place where every bloc error is reported.
///
/// Keeps the `catch` blocks inside the cubits free of logging, and gives the
/// app one seam to plug a crash reporter into later. Note that it only sees
/// errors a cubit hands over with `addError`.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
