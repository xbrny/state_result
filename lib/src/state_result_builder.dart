import 'package:flutter/material.dart';

import 'state_result.dart';

class StateResultBuilder<T> extends StatelessWidget {
  const StateResultBuilder({
    Key key,
    @required this.result,
    this.onIdle,
    this.onFailure,
    this.onLoading,
    @required this.onSuccess,
  })  : assert(result != null),
        assert(onSuccess != null),
        super(key: key);

  final StateResult<T> result;
  final WidgetBuilder onLoading;
  final WidgetBuilder onIdle;
  final ValueChangedWidgetBuilder<String> onFailure;
  final ValueChangedWidgetBuilder<T> onSuccess;

  @override
  Widget build(BuildContext context) {
    Widget widget = SizedBox.shrink();
    if (result.isIdle) {
      widget = onIdle?.call(context) ?? widget;
    }
    if (result.isLoading) {
      widget = onLoading?.call(context) ?? CircularProgressIndicator();
    }
    if (result.isFailure) {
      widget = onFailure?.call(context, result.message) ?? Text(result.message);
    }
    if (result.isSuccess) {
      widget = onSuccess?.call(context, result.data) ?? widget;
    }
    return widget;
  }
}

typedef ValueChangedWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
);
