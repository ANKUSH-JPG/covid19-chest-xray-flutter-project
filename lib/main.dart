import "package:flutter/material.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main()
{
  runApp(corona_19());
}

class corona_19 extends StatefulWidget {
  @override
  _corona_19State createState() => _corona_19State();
}

class _corona_19State extends State<corona_19> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "COVID19 PREDICTOR",
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: home_task(),
    );
  }
}

class home_task extends StatefulWidget {
  @override
  _home_taskState createState() => _home_taskState();
}

class _home_taskState extends State<home_task> {

  bool _isLoading;
  File _isImage;
  List _output;
  @override

  void initState(){
    super.initState();

    _isLoading=true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COVID19-PREDICTOR"),
        centerTitle: true,
      ),
      body: Center(
    child:Column(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(20),),
            _isImage==null?Container():Expanded(child:Image.file(_isImage,width: 400,height: 400,)),
            SizedBox(height: 1,),
            Padding(padding: const EdgeInsets.all(40),),
            RaisedButton(
              color: Colors.green,

              onPressed: (){
                selectImage();
              },
              child: Text("ADD IMAGE"),
            ),

            Text("THE RESULT IS:"),
            _output==null?Text("SELECT IMAGE"): Text("${_output[0]["label"]}")
          ],
      ),
    ),
    );
  }

  selectImage() async{
    var get_Image=await ImagePicker.pickImage(source: ImageSource.gallery);
    if(get_Image==null) return null;
    setState(() {
      _isLoading=true;
      _isImage=get_Image;
    });
    RunModelOnImage(get_Image);
  }
  
  RunModelOnImage(File image) async{
    var result=await Tflite.runModelOnImage(path: image.path,numResults:2,imageMean: 127.5,imageStd: 127.5,threshold: 0.5,asynch: true);
    setState(() {
      _isLoading=false;
      _output=result;
    });
  }
  loadModel() async{
    await Tflite.loadModel(model: "assets/model_unquant.tflite",labels: "assets/labels.txt");
  }
}

