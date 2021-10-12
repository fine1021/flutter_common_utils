import 'package:flutter/material.dart';

mixin RouteTransitionMixin<T extends StatefulWidget> on State<T> {
  ModalRoute<dynamic>? _route;
  List<VoidCallback> _pendingTasks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var animation = _route?.animation;
    animation?.removeStatusListener(_onAnimationStatusChanged);
    _route = ModalRoute.of(context);
    animation = _route?.animation;
    animation?.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    _pendingTasks.clear();
    var animation = _route?.animation;
    animation?.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_pendingTasks.isNotEmpty) {
        List<VoidCallback> localTasks = [];
        localTasks.addAll(_pendingTasks);
        localTasks.forEach((task) {
          _pendingTasks.remove(task);
          task();
        });
      }
    }
  }

  bool _handleScheduleTask(VoidCallback task) {
    var route = _route;
    if (route == null || route.animation == null) {
      return false;
    }
    var animation = route.animation!;
    if (route.offstage) {
      _pendingTasks.add(task);
    } else if (animation.isCompleted || animation.value > 0.9) {
      task();
    } else {
      _pendingTasks.add(task);
    }
    return true;
  }

  void scheduleTaskNextFrame(VoidCallback task) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      scheduleTask(task);
    });
  }

  void scheduleTask(VoidCallback task) {
    if (mounted) {
      if (!_handleScheduleTask(task)) {
        scheduleTaskNextFrame(task);
      }
    }
  }
}
