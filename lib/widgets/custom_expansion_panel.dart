import 'package:flutter/material.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this); // Increase the duration for a more noticeable effect
    _heightFactor = _controller.drive(CurveTween(
        curve:
            Curves.bounceOut)); // Use Curves.bounceOut for a bounce at the end
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.selected != null &&
        (widget.value == widget.selected ||
            widget.value == (widget.selected! + 1))) {
      widget.onChanged(null);
    } else {
      widget.onChanged(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpanded;
    if (widget.selected == null) {
      isExpanded = false;
    } else {
      isExpanded = widget.value == widget.selected;
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
          GestureDetector(
            onTap: _handleTap,
            child: widget.header,
          ),
          SizeTransition(
            sizeFactor: _heightFactor,
            child: GestureDetector(
              onTap: _handleTap, // Close the panel when the body is pressed
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
