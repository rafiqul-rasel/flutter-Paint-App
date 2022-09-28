import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Paint App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double height,width;
  List<Offset> points=[];
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  double currentStroke=1.2;
@override
  void initState() {

    super.initState();
  }
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void selectColor(){
    showDialog(
      context: context,
      builder:(ctx) =>AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(138, 35, 135, 1.0),
                    Color.fromRGBO(233, 64, 87, 1.0),
                    Color.fromRGBO(242, 113, 33, 1.0),
                  ]
              )
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height*.7,
                  width: width*.9,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10.5)),
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 10.5,
                        blurRadius: 10.5
                      )
                    ]
                  ) ,
                  child: GestureDetector(
                    onPanDown: (details){
                      setState(() {
                        points.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details){
                      setState(() {
                        points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details){
                      setState(() {
                        points.add(const Offset(-1, -1));
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(30.5)),
                      child: CustomPaint(
                        painter: MyCustomPainter(points,currentColor,currentStroke),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height*.02,),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20.5)),
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 10.5,
                            blurRadius: 10.5
                        )
                      ]
                  ),
                  width: width*.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(onPressed: (){
                        selectColor();
                      }, icon: Icon(Icons.color_lens)),
                      Expanded(child: Slider(
                        value: currentStroke,
                        onChanged: (double value) {
                          setState(() {
                            currentStroke=value;
                          });
                        },
                        min: 1,
                        max: 7,
                        activeColor: currentColor,
                      )),
                      IconButton(onPressed: (){
                        setState(() {
                          points.clear();
                        });
                      }, icon: Icon(Icons.layers_clear)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
class MyCustomPainter extends CustomPainter{
  List<Offset> points;
  Color color;
  double currentStroke;
  MyCustomPainter(this.points,this.color,  this.currentStroke);
  final offValue=const Offset(-1, -1);
  @override
  void paint(Canvas canvas, Size size) {
    Paint background=Paint()..color=Colors.white;
    Rect rect=Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    Paint paint=Paint();
    paint.color=color;
    paint.strokeWidth=currentStroke;
    paint.isAntiAlias=true;
    paint.strokeCap=StrokeCap.round;
    for(int i=0;i<points.length-1;i++){
      if(points[i]!=offValue && points[i+1]!=offValue) {
        canvas.drawLine(points[i], points[i+1], paint);
      }else if(points[i]!=offValue && points[i+1]==offValue){
        canvas.drawPoints(PointMode.points, points, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
