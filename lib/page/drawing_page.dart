import 'package:flutter/material.dart';
import '../models/saved_data.dart';
import '../widgets/interactable_svg.dart';
import 'package:flutter/scheduler.dart';
import '../models/region.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class DrawingPage extends StatefulWidget {
  const DrawingPage({
    super.key,
    required this.svgPath,
    required this.fixedAreaColoring,
  });

  final bool fixedAreaColoring;
  final String svgPath;

  @override
  State<DrawingPage> createState()=>  _DrawingPageState();
}

final GlobalKey<InteractableSvgState> mapKey = GlobalKey();

class _DrawingPageState extends State<DrawingPage>{
  late final AppLifecycleListener _listener;
  late AppLifecycleState? _state;

  late List<Region> _dataToSave;

  final List<Color> _colorList=[];
  int _selected=0; // 0:Fill,1:brush,2:clear
  Color _selectColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onInactive: () => _saveData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: BackButton(
            color: Colors.black,
            onPressed:(){
              _saveData();
              Navigator.pop(context);
              },
        ),
      ),
      body: Center(
        child:Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                scaleEnabled: true,
                panEnabled: false,
                constrained: true,
                maxScale:10,
                child: InteractableSvg(
                  key: mapKey,
                  selectedTool: _selected,
                  svgAddress: widget.svgPath,
                  selectColor:_selectColor,
                  fixedAreaColoring: widget.fixedAreaColoring,
                  onChanged: (colorMap) {
                    setState(() {
                      _colorList.clear();
                      colorMap.forEach((key, value) {
                        if(value>0){
                          _colorList.add(key);
                        }
                      });
                    });
                  },
                  onSave:(regionList){
                    _dataToSave=regionList;
                  },
                ),
              ),
            ),
            toolBar(),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colorList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                      onPressed:(){
                        setState(() {
                          _selectColor=_colorList[index];
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.black,
                              width:1,
                              style: BorderStyle.solid
                          ),
                          backgroundColor:_colorList[index],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.elliptical(25,25))
                          )
                      ),
                      child:Column()
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row toolBar() {
   if(!widget.fixedAreaColoring){
     return Row(children: [
       ElevatedButton(onPressed: ()=> setState(() {
         _selected = 1;
       }), child: Text('pen')),
       ElevatedButton(onPressed: ()=> setState(() {
         _selected = 2;
       }), child: Text('clear')),
       ElevatedButton(onPressed: ()=> setState(() {
         _selected = 0;
       }), child: Text('fill')),
     ],
     );
   }
   return Row();
  }

  Future _saveData() async {
    /*
    List<SavedData> dataList=[];
    if(_dataToSave!=null){
      _dataToSave.forEach((element) {
        if(element.fillColor != null){
          dataList.add(SavedData(element.id,element.fillColor.value));
        }
      });
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = await File('${directory.path}/saved_${widget.svgPath.replaceAll('.svg', '.json')}');
    if(!await file.exists()){
      file.create(recursive: true).whenComplete(() => file.writeAsString(json.encode(dataList)));
    }else{
      file.writeAsString(json.encode(dataList));
    }*/
  }
}

