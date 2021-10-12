import 'package:flutter/material.dart';

final RouteObserver<Route<dynamic>> routeObserver = RouteObserver();

mixin RouteAwareMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  bool _isResumed = false;

  bool get isResumed => _isResumed;

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @mustCallSuper
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @mustCallSuper
  @override
  void didPop() {
    _isResumed = false;
  }

  @mustCallSuper
  @override
  void didPopNext() {
    _isResumed = true;
    onResume(false);
  }

  @mustCallSuper
  @override
  void didPush() {
    _isResumed = true;
    onResume(true);
  }

  @mustCallSuper
  @override
  void didPushNext() {
    _isResumed = false;
  }

  /// 当页面可见的时候的回调，可以在此处做一些UI数据获取等操作。
  /// [initial]为true则表明是第一次可见，否则为false
  @protected
  void onResume(bool initial) {}
}
