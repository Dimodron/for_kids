import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/region.dart';
import '../controllers/size_controller.dart';
import 'dart:ui' as ui;

class RegionPainter extends CustomPainter {
  final Region region;
  final Color? strokeColor;
  final double? strokeWidth;
  final Color? canvasBack;
  final Color? selectColor;
  final bool fixedAreaColoring;
  //final Function(Canvas canvas) onDraw;


  final sizeController = SizeController.instance;

  double _scale = 1.0;

  RegionPainter({
    required this.region,
    required this.fixedAreaColoring,
    //required this.onDraw,
    this.canvasBack,
    this.strokeColor,
    this.strokeWidth,
    this.selectColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = strokeColor ?? Colors.black45
      ..strokeWidth = strokeWidth ?? 1.0
      ..style = PaintingStyle.stroke;

    final background = Paint()
      ..color = region.regionFillColor ?? Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final brush = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
    ;
    Path brushPath = Path();

    // canvas optimization

    _scale = region.scale??sizeController.calculateScale(size);

    canvas.scale(_scale);

    if (!region.shifted) {
      region.regionPath = region.regionPath.shift(Offset(
          (size.width - sizeController.mapSize.width * _scale) * 0.5,
          (size.height - sizeController.mapSize.height * _scale) * 0.5));
      region.shifted = true;
      region.scale = _scale;
    }

    canvas.clipPath(region.regionPath);

    // work with colors


    if (fixedAreaColoring) {
      if (region.selectedRegion && region.regionFillColor != selectColor) {
        background.color = Colors.white;
      }
      if (region.selectedRegion && region.regionFillColor == selectColor) {
        background.shader = ImageShader(
            region.regionFillTexture!, TileMode.repeated, TileMode.repeated, Matrix4
            .identity()
            .storage);
        background.colorFilter =
            ColorFilter.mode(region.regionFillColor ?? Colors.white, BlendMode.color);
      }
    }

    canvas.drawPath(region.regionPath, background);

    if(region.brush.isNotEmpty){
      region.brush.forEach((element) {
        if(element.path.isNotEmpty){
          brush.color = element.color;
          brushPath.addPolygon(element.path,false);
          canvas.drawPath(brushPath,brush);
          brushPath=Path();
        }
      });
    }

    canvas.drawPath(region.regionPath, border);
   // region.repaint  = false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate){
   return region.repaint;
  }

  @override
  bool hitTest(Offset position) {
    double inverseScale = sizeController.inverseOfScale(_scale);
    return region.regionPath.contains(position.scale(inverseScale, inverseScale));
  }
}
