import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'region_painter.dart';
import '../models/region.dart';
import '../parser/svg_parser.dart';
import '../parser/color_parser.dart';
import '../controllers/size_controller.dart';
import 'package:flutter/widgets.dart';

class InteractableSvg extends StatefulWidget {
  final String svgAddress;
  final double? canvasHeight;
  final Color? selectColor;
  final bool fixedAreaColoring;
  final int selectedTool;
  final Function(Map<Color,int> colorMap) onChanged;
  final Function(List<Region> regionList) onSave;


  const InteractableSvg({
    Key? key,
    required this.svgAddress,
    required this.onChanged,
    required this.onSave,
    required this.fixedAreaColoring,
    required this.selectedTool,
    this.canvasHeight,
    this.selectColor,
  }):super(key: key);

  @override
  InteractableSvgState createState() => InteractableSvgState();
}

class InteractableSvgState extends State<InteractableSvg> {
  final List<Region> _regionList = [];
  late Map<Color,int> _colorMap;
  final sizeController = SizeController.instance;

  @override
  void initState() {
    super.initState();
    sizeController.restart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegionList();
    });
  }

  _loadRegionList() async {
    late final List<Region> list;
    list = await SvgParser.instance.svgToRegionList(widget.svgAddress,widget.fixedAreaColoring);
    setState(() {
      _regionList.addAll(list);
      _colorMap=(widget.fixedAreaColoring)?ColorParser.getRegionColors(list):ColorParser.getColors();
      widget.onChanged.call(_colorMap);
    });
  }

  void _onPointerDown(Region region){
    region.repaint = true;
    setState(() {
      region.brush.add(Brush(color: widget.selectColor!, path:[]));
      if(widget.fixedAreaColoring){
        if(region.selectedRegion && region.regionFillColor == widget.selectColor){
          _colorMap[region.regionFillColor!]=_colorMap[region.regionFillColor!]!-1;
          widget.onChanged.call(_colorMap);
          region.selectedRegion = false;
        }
      }else{
        if(widget.selectedTool == 0){
          region.regionFillColor=widget.selectColor!;
        }
        if(widget.selectedTool == 2){
          region.regionFillColor = Colors.white;
        }
      }
    });
  }

  void _onPointerMove(PointerMoveEvent details,Region region){
      setState(() {
        if(widget.selectedTool==1){ // 0:Fill,1:brush,2:clear
          region.brush.last.path.add(details.localPosition/region.scale!);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    widget.onSave.call(_regionList);
    return Stack(
      children: <Widget>[
        for (var region in _regionList)_buildStackItem(region),
      ],
    );
  }

  Widget _buildStackItem(Region region) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _onPointerDown(region),
      onPointerMove: (details)=>_onPointerMove(details,region),
      child: CustomPaint(
        foregroundPainter: RegionPainter(
          region: region,
          selectColor:widget.selectColor,
          strokeColor: Colors.black,
          strokeWidth: 2.0,
          fixedAreaColoring: widget.fixedAreaColoring,
        ),
        child: Container(),
      ),
    );
  }
}
