import 'package:flutter/material.dart';

class ExpandedSingleChildScrollView extends StatelessWidget {
  const ExpandedSingleChildScrollView({
    Key key,
    this.child,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.margin,
    this.physics,
    this.withIntrinsicHeight,
    this.withSafeArea,
    this.controller,
  }) : super(key: key);

  final Widget child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Decoration decoration;
  final EdgeInsetsGeometry margin;
  final ScrollPhysics physics;
  final bool withIntrinsicHeight;
  final bool withSafeArea;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    Widget result = LayoutBuilder(builder: (context, constraints) {
      Widget result = child;
      if (withIntrinsicHeight ?? false) {
        result = IntrinsicHeight(child: child);
      }
      return ListView(
        physics: physics ?? AlwaysScrollableScrollPhysics(),
        controller: controller,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: result,
            alignment: alignment ?? Alignment.center,
            padding: padding,
            color: color,
            decoration: decoration,
            margin: margin,
          ),
        ],
      );
    });

    if (withSafeArea ?? false) {
      result = SafeArea(child: result);
    }

    return result;
  }
}
