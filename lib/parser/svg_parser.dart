import 'package:flutter/services.dart' show rootBundle;
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:flutter/material.dart';
import '../controllers/size_controller.dart';
import '../constant/constant.dart';
import '../models/region.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/saved_data.dart';
import '../parser/color_parser.dart';
import 'dart:ui' as ui;

class SvgParser {
  static SvgParser? _instance;

  static SvgParser get instance {
    _instance ??= SvgParser._init();
    return _instance!;
  }

  final sizeController = SizeController.instance;

  SvgParser._init();

  Future<List<Region>> svgToRegionList(String svgAddress,bool fixedAreaColoring) async {
    final svgMain = await rootBundle.loadString(svgAddress);
    final svg = svgMain.replaceAll("\r\n", "");
    int id = 0;
    List<Region> regionList = [];
    Map<int,Color> _savedColorsMap={};
    ui.Image? fillTexture =(fixedAreaColoring)?await ColorParser.getUiImage('assets/cage.jpg',100,100):null;

    await loadData(svgAddress).then((value) => _savedColorsMap.addAll(value));
    final regExpRegion = RegExp(Constants.mapRegexp,multiLine: true, caseSensitive: false, unicode: true, dotAll: false);

    regExpRegion.allMatches(svg).forEach((regionData) {
      final region = Region(
          id: id,
          regionPath: parseSvgPath(regionData.group(4)!),
          regionFillColor:hexToColor(regionData.group(1)!),
          regionFillTexture: fillTexture,
          selectedRegion: fixedAreaColoring,
      );

      if(_savedColorsMap[region.id]!=null){
        region.regionFillColor=_savedColorsMap[region.id]!;
      }

      sizeController.addBounds(region.regionPath.getBounds());
      regionList.add(region);
      id++;
    });
    return regionList;
  }

  Future<Map<int,Color>> loadData(String svgAddress) async{
    final directory = await getApplicationDocumentsDirectory();
    final file = await File('${directory.path}/saved_${svgAddress.replaceAll('.svg', '.json')}');
    Map<int,Color> data = {};
    try{
      final decoded = jsonDecode(await file.readAsString());
      for(final item in decoded){
        SavedData arr = SavedData.fromJson(item);
        data[arr.id]=Color(arr.color);
      }
    }catch(e){
      return {};
    }
    return data;
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1,7), radix: 16) + 0xFF000000);
  }

}
