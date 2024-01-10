import 'package:flutter/material.dart';
import 'package:currency_app/constants.dart';

class ScrollBar extends StatefulWidget {
  final List<GlobalKey> sectionKeys;

  const ScrollBar({super.key, required this.sectionKeys});

  @override
  ScrollBarState createState() => ScrollBarState();
}

class ScrollBarState extends State<ScrollBar> {
  Color _backgroundColor = const Color.fromARGB(255, 124, 124, 124);
  int _selectedIndex = -1;

  void _onPointerDown(PointerDownEvent details) {
    setState(() {
      _backgroundColor = Colors.lightBlue;
    });
  }

  void _onPointerUp(PointerUpEvent details) {
    setState(() {
      _backgroundColor = const Color.fromARGB(255, 124, 124, 124);
    });
  }

  int calculateIndex(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);
    double itemHeight = box.size.height / widget.sectionKeys.length;
    return (localPosition.dy ~/ itemHeight)
        .clamp(0, widget.sectionKeys.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: SizedBox(
        width: 20,
        child: GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) async {
            int index = calculateIndex(details.globalPosition);
            await Scrollable.ensureVisible(
              widget.sectionKeys[index].currentContext!,
            );
            setState(() {
              _selectedIndex = index;
            });
          },
          onVerticalDragEnd: (DragEndDetails details) {
            setState(() {
              _selectedIndex = -1;
            });
          },
          child: Column(
            children: List.generate(
              widget.sectionKeys.length,
              (index) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      color: index == _selectedIndex
                          ? Colors.red
                          : _backgroundColor,
                      child: Center(
                        child: Text(
                          mapSectionToKey.keys.elementAt(index),
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
