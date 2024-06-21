import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'drawing_page.dart';
import '../constant/file_list.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.color_lens),
            label: 'Расскраска',
          ),
          NavigationDestination(
            icon: Icon(Icons.area_chart_outlined),
            label: 'Расскраска по областям',
          ),
        ],
      ),
      body: <Widget>[
        buildGridView(context,FileList.freeColorList),
        buildGridView(context,FileList.areaColorList),
        ][currentPageIndex],
    );
  }

  GridView buildGridView(BuildContext context,List<String> pathList) {
    return GridView.count(
        crossAxisCount: 3,
        children:List.generate(pathList.length, (index) {
          return GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () => _navigateToNextScreen(context, pathList[index]),
            child:Center(
              child:  SvgPicture.asset(
                pathList[index],
                fit: BoxFit.contain,
                height: 100,
                width: 70,
              ),
            ),
          );
        }),
      );
  }

  void _navigateToNextScreen(BuildContext context, String path) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DrawingPage(svgPath: path,fixedAreaColoring:(currentPageIndex==0)?false:true,)));
  }
}
