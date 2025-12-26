import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../ui/colors.dart';
import '../utils/screen_factor.dart';

class SwipeTo extends StatefulWidget {
  /// Child widget for which you want to have horizontal swipe action
  /// @required parameter
  final Widget child;

  /// Icon for which you want to have on horizontal swipe action appearing
  /// @required parameter
  final Icon actionIcon;

  /// Double value till which position child widget will get animate when swipe left
  /// or swipe right
  /// if not specified 0.3 default will be taken for Right Swipe &
  /// it's negative -0.3 will bve taken for Left Swipe
  final double offsetDx;

  /// callback which will be initiated at the end of child widget animation
  /// when swiped right
  /// if not passed swipe to right will be not available
  final VoidCallback onSwipe;

  /// Integer specifying value above which it will sense swipe to get triggered
  /// default minimum value is 20 and maximum value is 35
  /// Putting max value will require use to swipe in short time to get swipe in effect
  final int swipeSensitivity;

  final bool stickToRight;

  final DismissDirection direction;

  const SwipeTo({
    super.key,
    required this.child,
    required this.actionIcon,
    required this.onSwipe,
    this.offsetDx = 0.33, // change from 0.3 to 0.35 to limit sliding
    this.swipeSensitivity = 5,
    required this.direction,
    required this.stickToRight,
  }) : assert(swipeSensitivity >= 5 && swipeSensitivity <= 35,
            "swipeSensitivity value must be between 5 to 35");

  @override
  SwipeToState createState() => SwipeToState();
}

const double _kDismissThreshold = 0.4;
const double _dragExtentLimit = 120;

class SwipeToState extends State<SwipeTo> with TickerProviderStateMixin {
  late Animation<Offset> _moveAnimation;

  ConfirmDismissCallback? confirmDismiss;

  final Map<DismissDirection, double> dismissThresholds =
      const <DismissDirection, double>{};

  DismissDirection _extentToDirection(double extent) {
    if (extent == 0.0) {
      return DismissDirection.none;
    }
    if (_directionIsXAxis) {
      return switch (Directionality.of(context)) {
        TextDirection.rtl when extent < 0 => DismissDirection.startToEnd,
        TextDirection.ltr when extent > 0 => DismissDirection.startToEnd,
        TextDirection.rtl || TextDirection.ltr => DismissDirection.endToStart,
      };
    }
    return extent > 0 ? DismissDirection.down : DismissDirection.up;
  }

  DismissDirection get _dismissDirection => _extentToDirection(_dragExtent);

  double get _dismissThreshold =>
      dismissThresholds[_dismissDirection] ?? _kDismissThreshold;

  double _dragExtent = 0.0;
  bool _confirming = false;
  bool _dragUnderway = false;

  Duration movementDuration = const Duration(milliseconds: 200);
  double crossAxisEndOffset = 0.0;

  bool get _directionIsXAxis {
    return true;
  }

  double get _overallDragAxisExtent {
    final Size size = context.size!;
    return _directionIsXAxis ? size.width : size.height;
  }

  late final AnimationController _moveController = AnimationController(
    duration: movementDuration,
    vsync: this,
  );

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;
    _moveAnimation = _moveController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: Offset(widget.stickToRight ? -widget.offsetDx : widget.offsetDx,
            crossAxisEndOffset),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    _updateMoveAnimation();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_confirming) {
      return;
    }
    _dragUnderway = true;
    if (_moveController.isAnimating) {
      _dragExtent =
          _moveController.value * _overallDragAxisExtent * _dragExtent.sign;
      _moveController.stop();
    } else {
      _dragExtent = 0.0;
      _moveController.value = 0.0;
    }
    setState(() {
      _updateMoveAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway || _moveController.isAnimating) {
      return;
    }

    final double delta = details.primaryDelta!;
    final double oldDragExtent = _dragExtent;
    switch (widget.direction) {
      case DismissDirection.horizontal:
      case DismissDirection.vertical:
        _dragExtent += delta;

      case DismissDirection.up:
        if (_dragExtent + delta < 0) {
          _dragExtent += delta;
        }

      case DismissDirection.down:
        if (_dragExtent + delta > 0) {
          _dragExtent += delta;
        }

      case DismissDirection.endToStart:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta > 0) {
              _dragExtent += delta;
            }
          case TextDirection.ltr:
            if (_dragExtent + delta < 0) {
              _dragExtent += delta;
            }
        }

      case DismissDirection.startToEnd:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta < 0) {
              _dragExtent += delta;
            }
          case TextDirection.ltr:
            if (_dragExtent + delta > 0) {
              _dragExtent += delta;
            }
        }

      case DismissDirection.none:
        _dragExtent = 0;
    }
    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {
        _updateMoveAnimation();
      });
    }
    // bool isEndPosition = widget.stickToRight? _dragExtent > -_dragExtentLimit : _dragExtent < _dragExtentLimit;
    bool isEndPosition = _moveController.value > widget.offsetDx;
    if (!_moveController.isAnimating && !isEndPosition) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway || _moveController.isAnimating) {
      return;
    }
    _dragUnderway = false;
    if (_moveController.isCompleted) {
      _handleMoveCompleted();
      return;
    }
    if (!_moveController.isDismissed) {
      // we already know it's not completed, we check that above
      if (_moveController.value > _dismissThreshold) {
        _moveController.forward();
      } else {
        _moveController.reverse();
      }
    }

    if (_moveController.value > widget.offsetDx) {
      widget.onSwipe();
    }
  }

  Future<bool> _confirmStartResizeAnimation() async {
    if (confirmDismiss != null) {
      _confirming = true;
      final DismissDirection direction = _dismissDirection;
      try {
        return await confirmDismiss!(direction) ?? false;
      } finally {
        _confirming = false;
      }
    }
    return true;
  }

  Future<void> _handleMoveCompleted() async {
    if (_dismissThreshold >= 1.0) {
      _moveController.reverse();
      return;
    }
    final bool result = await _confirmStartResizeAnimation();
    if (mounted) {
      if (result) {
        // _startResizeAnimation();
      } else {
        _moveController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget background = Padding(
        padding: widget.stickToRight
            ? const EdgeInsets.only(right: 8)
            : const EdgeInsets.only(left: 8),
        child: widget.actionIcon);

//OR
//     Widget background = Padding(
//       padding: widget.stickToRight
//           ? const EdgeInsets.only(right: 8)
//           : const EdgeInsets.only(left: 8),
//       child: ActionIcon(
//         icon: widget.icon,
//         moveAnimation: _moveAnimation,
//       ),
//     );

    Widget content = SlideTransition(
      position: _moveAnimation,
      child: widget.child,
    );

    content = Stack(
      alignment:
          widget.stickToRight ? Alignment.centerRight : Alignment.centerLeft,
      fit: StackFit.passthrough,
      children: <Widget>[
        if (!_moveAnimation.isDismissed)
          Align(
            alignment: widget.stickToRight
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ClipRect(
              clipper: _DismissibleClipper(
                axis: Axis.horizontal,
                moveAnimation: _moveAnimation,
              ),
              child: background,
            ),
          ),
        content,
      ],
    );

    if (widget.direction == DismissDirection.none) {
      return content;
    }

    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.start,
      child: content,
    );
  }
}

class _DismissibleClipper extends CustomClipper<Rect> {
  _DismissibleClipper({required this.axis, required this.moveAnimation})
      : super(reclip: moveAnimation);

  final Axis axis;
  final Animation<Offset> moveAnimation;

  @override
  Rect getClip(Size size) {
    var sizeWidth = screenWidth;
    final double offset = moveAnimation.value.dx * sizeWidth;
    if (offset < 0) {
      return Rect.fromLTRB(size.width + offset, 0.0, size.width, size.height);
    }
    return Rect.fromLTRB(0.0, 0.0, offset, size.height);
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_DismissibleClipper oldClipper) {
    return oldClipper.axis != axis ||
        oldClipper.moveAnimation.value != moveAnimation.value;
  }
}

class ActionIcon extends StatefulWidget {
  const ActionIcon(
      {super.key, required this.icon, required this.moveAnimation});

  final Icon icon;

  final Animation<Offset> moveAnimation;

  @override
  ActionIconState createState() => ActionIconState();
}

class ActionIconState extends State<ActionIcon> with TickerProviderStateMixin {
  double animationValue = 0.0;

  @override
  void initState() {
    widget.moveAnimation.addListener(() {
      if (mounted) {
        setState(() {
          animationValue = (widget.moveAnimation.value.dx * 10).abs();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.icon.size!),
            color: animationValue >= 1.0
                ? Colors.grey.shade300
                : Colors.transparent,
          ),
          height: widget.icon.size! + 5,
          width: widget.icon.size! + 5,
          child: CircularProgressIndicator(
            value: animationValue,
            backgroundColor: Colors.transparent,
            strokeWidth: 1.5,
            color: gainsborough,
          ),
        ),
        Transform.scale(
          scale: animationValue,
          child: Icon(
            widget.icon.icon,
            color: widget.icon.color,
            size: widget.icon.size! - 5,
          ),
        ),
      ],
    );
  }
}
