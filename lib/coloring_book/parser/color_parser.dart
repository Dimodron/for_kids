import '../models/region.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
class ColorParser {
  static ColorParser? _instance;
  static ColorParser get instance {
    _instance ??= ColorParser._init();
    return _instance!;
  }
  ColorParser._init();

   static Map<Color,int> getRegionColors(List<Region> list){
     Map<Color,int> pallet = {};
     for (var region in list) {
       pallet[region.regionFillColor!]=(pallet[region.regionFillColor]==null)?0:pallet[region.regionFillColor]!;
       if(region.selectedRegion){
         pallet[region.regionFillColor!]=pallet[region.regionFillColor]!+1;
       }
     }
     return pallet;
    }

   static Map<Color,int> getColors(){ // переделать палитру
     Map<Color,int> pallet={};
     List <Color> col=[];
     for (int i=0;i<=250;i += 100){
       for (int j=0;j<=250;j += 100)
       {
         for (int k=0;k<=250;k += 100)
         {
           pallet[Color.fromRGBO(i, j, k, 1)]=1;
         }
       }
     }
     return pallet;
   }

   static Future<ui.Image> getUiImage(String imageAssetPath, int height, int width) async {
     final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
     image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List())!;
     image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
     ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
     ui.FrameInfo frameInfo = await codec.getNextFrame();
     return frameInfo.image;
   }
}