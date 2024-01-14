import 'package:flutter/material.dart';
import 'package:currency_app/my_app_state.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class CustomExpansionPanel extends StatefulWidget {
  final Widget header;
  final Widget body;
  final int value;
  final int? selected;
  final ValueChanged<int?> onChanged;
  final bool isVisible;

  const CustomExpansionPanel({
    super.key,
    required this.header,
    required this.body,
    required this.value,
    required this.selected,
    required this.onChanged,
    required this.isVisible,
  });

  @override
  CustomExpansionPanelState createState() => CustomExpansionPanelState();
}

class CustomExpansionPanelState extends State<CustomExpansionPanel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool isExpanded = false;
  bool _swipeActionPerformed = false;
  bool _tapDisabled = false;
  double _dragDistance = 0;
  late AnimationController _dragController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this); // Increase the duration for a more noticeable effect
    _heightFactor = _controller.drive(CurveTween(
        curve:
            Curves.elasticIn)); // Use Curves.bounceOut for a bounce at the end

    _dragController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(parent: _dragController, curve: Curves.bounceOut));

    _dragController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragDistance = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_tapDisabled) return;

    _tapDisabled = true;
    Timer(const Duration(milliseconds: 1750), () {
      _tapDisabled = false;
    });

    if (widget.selected != null &&
        (widget.value == widget.selected ||
            widget.value == (widget.selected! + 1))) {
      setState(() {
        _heightFactor = _controller.drive(CurveTween(curve: Curves.elasticIn));
      });
      widget.onChanged(null);
    } else {
      setState(() {
        _heightFactor = _controller.drive(CurveTween(curve: Curves.elasticOut));
      });
      widget.onChanged(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (widget.selected == null) {
      setState(() {
        isExpanded = false;
      });
    } else {
      setState(() {
        isExpanded = widget.value == widget.selected;
      });
    }

    if (isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Visibility(
      visible: widget.isVisible,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 10.99,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: Colors.white, width: .1), // Add bottom border here
              ),
            ),
            child: GestureDetector(
              onTap: _handleTap,
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  _dragDistance += details.delta.dx;
                  _dragDistance = _dragDistance.clamp(-40.0, 40.0);
                });
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                var dragDistance = _dragDistance;
                _dragController.reset();
                _animation = Tween(begin: dragDistance, end: 0.0).animate(
                    CurvedAnimation(
                        parent: _dragController, curve: Curves.bounceOut))
                  ..addListener(() {
                    setState(() {
                      _dragDistance = _animation.value;
                    });
                  });
                _dragController.forward();
              },
              child: AnimatedBuilder(
                animation: _dragController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_dragDistance, 0),
                    child: widget.header,
                  );
                },
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _heightFactor,
            child: GestureDetector(
              onTap: _handleTap, // Close the panel when the body is pressed
              // onHorizontalDragUpdate: (DragUpdateDetails details) {
              //   if (!_swipeActionPerformed && details.delta.dx > 3) {
              //     appState.decreaseFactor();
              //     _swipeActionPerformed = true;
              //   } else if (!_swipeActionPerformed && details.delta.dx < -3) {
              //     appState.increaseFactor();
              //     _swipeActionPerformed = true;
              //   }
              // },
              // onHorizontalDragEnd: (DragEndDetails details) {
              //   _swipeActionPerformed = false;
              // },
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.white,
                        width: .1), // Add bottom border here
                  ),
                ),
                child: widget.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
