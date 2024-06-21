import 'package:flutter/material.dart';
import 'dart:ui' as ui;
class Region {
  int id;
  Path regionPath;
  bool shifted;
  bool repaint;
  double? scale;
  ui.Image? regionFillTexture;
  Color? regionFillColor;
  bool selectedRegion;
  List<Brush> brush = [];
  Region({
    required this.id,
    required this.regionPath,
    this.regionFillColor,
    this.regionFillTexture,
    this.selectedRegion = false,
    this.shifted = false,
    this.repaint = true,
    this.scale,
  });
}

class Brush{
  Color color;
  List<Offset> path;
  Brush({
   required this.color,required this.path,
  });
}