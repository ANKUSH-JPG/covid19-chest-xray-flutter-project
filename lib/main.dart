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
  open_gallery(BuildContext context) async{

    var get_Image=await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      _isImage=get_Image;
    });
    if(get_Image==null) return null;
    setState(() {
      _isLoading=true;
      _isImage=get_Image;
    });
    RunModelOnImage(get_Image);
    Navigator.of(context).pop();
  }
  open_camera(BuildContext context) async{
    var get_Image=await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      _isImage=get_Image;
    });
    setState(() {
      _isLoading=true;
      _isImage=get_Image;
    });
    RunModelOnImage(get_Image);
    Navigator.of(context).pop();
  }
  Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Text(" SELECT ONE "),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text('GALLERY'),
                onTap: (){// open gallery for US

                  open_gallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(5.0),),
              GestureDetector(
                child: Text('CAMERA'),
                onTap: (){// open camera for US

                  open_camera(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void initState(){
    super.initState();

    _isLoading=true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget display_image(){
    if(_isImage==null)
    {
      return Text("NO IMAGE SELECTED(SELECT THE XRAY IMAGE TO PREDICT )");
    }
    else
    {
      return Image.file(_isImage,width: 400,height: 400,);
    }
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
            display_image(),
            Padding(padding: const EdgeInsets.all(80),),
            RaisedButton(
              color: Colors.green,

              onPressed: (){
                _showChoiceDialog(context);
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

