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
  bool _tapDisabled = false;
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this); // Increase the duration for a more noticeable effect
    _heightFactor = _controller.drive(CurveTween(
        curve:
            Curves.elasticIn)); // Use Curves.bounceOut for a bounce at the end
  }

  @override
  void dispose() {
    _controller.dispose();
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
              child: widget.header,
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
