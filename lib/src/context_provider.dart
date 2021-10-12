import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ContextProvider {
  static final ContextProvider _instance = ContextProvider._internal();

  factory ContextProvider() => _instance;

  ContextProvider._internal();

  Set<_Pair<ContextAware, BuildContext?>> pairs = Set();

  void subscribe(ContextAware contextAware, BuildContext context) {
    _Pair<ContextAware, BuildContext?> pair = _Pair(contextAware, context);
    pairs.add(pair);
  }

  void unsubscribe(ContextAware contextAware) {
    _Pair<ContextAware, BuildContext?> pair = _Pair(contextAware, null);
    pairs.remove(pair);
  }

  BuildContext? get context {
    if (pairs.isNotEmpty) {
      return pairs.last.second;
    }
    return null;
  }

  static BuildContext getContext() {
    BuildContext? context = ContextProvider().context;
    context ??= navigatorKey.currentState?.overlay?.context;
    if (context == null) {
      throw Exception('context is null. try use [getContextAsync]');
    }
    return context;
  }

  static void getContextAsync(
    ContextGetter getter, [
    Duration duration = Duration.zero,
  ]) {
    Future.delayed(duration, () {
      BuildContext context = getContext();
      getter(context);
    });
  }
}

typedef ContextGetter = void Function(BuildContext context);

abstract class ContextAware {}

class _Pair<F, S> {
  F first;
  S second;

  _Pair(this.first, this.second);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Pair &&
          runtimeType == other.runtimeType &&
          first == other.first;

  @override
  int get hashCode => first.hashCode;
}

mixin ContextAwareMixin<T extends StatefulWidget> on State<T>
    implements ContextAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ContextProvider().subscribe(this, context);
  }

  @override
  void dispose() {
    ContextProvider().unsubscribe(this);
    super.dispose();
  }
}
