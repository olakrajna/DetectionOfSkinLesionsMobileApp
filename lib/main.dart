import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcapp/home.dart';
import 'package:mcapp/onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

bool? seenOnboard;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCA',
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: seenOnboard == true ? Home(): OnBoard(),
    );
  }
}

late List<CameraDescription> cameras;
late List<CameraDescription> secondCameras;

Future<void> main() async {
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  // to load onboard for the first time only
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  seenOnboard = pref.getBool('seenOnboard') ?? false;

  runApp(const MyApp());
}

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? selectedImage;
  String? message = "";
  bool _imageSelected = false;

  uploadImage() async {
    final request = http.MultipartRequest("POST", Uri.parse("https://2d00-153-19-218-102.ngrok.io/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    print(selectedImage!
        .path
        .split("/")
        .last);
    request.files.add(
      http.MultipartFile('image', selectedImage!.readAsBytes().asStream(),
          selectedImage!.lengthSync(), 
          filename: selectedImage!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    print(message);
    if (!mounted) {
      return;
    }
    setState(() {

    });
  }


  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        selectedImage = File(image!.path);
        _imageSelected = true;
      });
      // Do something with the picked image if needed
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 500,
                width: 300,
                fit: BoxFit.cover,
              )
            else
              Text(
                'No image selected',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 20,
                ),
              ),
            SizedBox(height: 5),
            if (_imageSelected)
              Column(
                children: [
                  Text(
                    "Classification info",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            if (_imageSelected)
              GestureDetector(
                onTap: uploadImage,
                child: Container(
                  alignment: Alignment.center,
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(244, 178, 176, 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(
                          247,
                          0,
                          0,
                          0,
                        ),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        "Upload image",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                alignment: Alignment.center,
                width: 250,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 178, 176, 1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(
                        247,
                        0,
                        0,
                        0,
                      ),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(-4, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Pick image from gallery",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      Icons.linked_camera_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ImageCapture extends StatefulWidget{
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}


class _ImageCaptureState extends State<ImageCapture> {

  List<CameraDescription>? cameras;
  CameraController? imageController;
  XFile? image;
  bool isCaptured = false;
  bool showCamera = true;
  String? message = "";

  @override
  void initState() {
    super.initState();
    if (mounted) {
      loadImageCamera();
    }
  }

  uploadImage() async {
    if (!mounted) {
      return;
    }
    if (image != null) {
      File capturedFile = File(
          image!.path); // Tworzenie pliku File z przechwyconego obrazu
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("https://2d00-153-19-218-102.ngrok.io/upload"),
      );
      final headers = {"Content-type": "multipart/form-data"};
      print(image!
          .path
          .split("/")
          .last);
      request.files.add(
        http.MultipartFile(
          'image',
          capturedFile.readAsBytes().asStream(),
          capturedFile.lengthSync(),
          filename: capturedFile.path
              .split("/")
              .last,
        ),
      );
      request.headers.addAll(headers);
      final response = await request.send();
      http.Response res = await http.Response.fromStream(response);
      final resJson = jsonDecode(res.body);
      message = resJson['message'];
      print(message);
      setState(() {});
    } else {
      print('No image captured');
    }
  }


  loadImageCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      imageController = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      imageController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCaptured)
              Container(
                padding: EdgeInsets.all(30),
                child: image == null
                    ? Text("No image captured")
                    : Column(
                  children: [
                    Image.file(File(image!.path), height: 500),
                    SizedBox(height: 10),
                    Text("Classification info",
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20),),
                    SizedBox(height: 5),
                    Text(message ?? '',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20),),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: uploadImage,
                      child: Container(
                        alignment: Alignment.center,
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(244, 178, 176, 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(247, 0, 0, 0),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              "Upload image ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Icon(Icons.cloud_upload_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCaptured = false;
                          showCamera = true; // Pokaż ponownie podgląd kamery
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(244, 178, 176, 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(247, 0, 0, 0),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              "Retake Photo",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Icon(Icons.refresh_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isCaptured && showCamera)
              Container(
                height: 500,
                width: 300,
                child: imageController == null
                    ? Center(child: Text("Loading Camera..."))
                    : !imageController!.value.isInitialized
                    ? Center(child: CircularProgressIndicator())
                    : CameraPreview(imageController!),
              ),
            SizedBox(height: 20),
            if (!isCaptured && showCamera)
              GestureDetector(
                onTap: () async {
                  try {
                    if (imageController != null &&
                        imageController!.value.isInitialized) {
                      image = await imageController!.takePicture();
                      setState(() {
                        isCaptured = true;
                        showCamera = false; // Ukryj aparat po zrobieniu zdjęcia
                      });
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(244, 178, 176, 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(247, 0, 0, 0),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        "Capture",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Icon(Icons.camera_outlined, color: Colors.white),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}