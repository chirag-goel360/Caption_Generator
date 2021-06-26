import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class LiveCaption extends StatefulWidget {
  @override
  _LiveCaptionState createState() => _LiveCaptionState();
}

class _LiveCaptionState extends State<LiveCaption> {
  String result = "Fetching Response...";
  List<CameraDescription> cameras;
  CameraController controller;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    isCapturing = true;
    detectCameras().then((_) {
      initializeController();
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initializeController() {
    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      if (isCapturing) {
        Duration interval = Duration(
          seconds: 5,
        );
        Timer.periodic(
          interval,
          (Timer t) => capturePictures(),
        );
      }
    });
  }

  capturePictures() async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_captions';
    await Directory(dirPath).create(
      recursive: true,
    );
    final String filePath = '$dirPath/{$timestamp}.png';
    if (isCapturing) {
      controller.takePicture(filePath).then((_) {
        if (isCapturing) {
          File imgFile = File(
            filePath,
          );
          fetchResponse(imgFile);
        } else {
          return;
        }
      });
    }
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData = lookupMimeType(
      image.path,
      headerBytes: [
        0xFF,
        0xD8,
      ],
    ).split('/');
    // Get your API Key from https://developers.redhat.com/courses/openshift/getting-started
    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse(
        'API Key'+'/model/predict',
      ),
    );
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(
        streamResponse,
      );
      final Map<String, dynamic> responseData = json.decode(
        response.body,
      );
      parseResponse(responseData);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void parseResponse(var response) {
    String value = "";
    var predictions = response['predictions'];
    for (var prediction in predictions) {
      var caption = prediction['caption'];
      value = value + '$caption\n';
    }
    setState(() {
      result = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.004,
              1,
            ],
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade200,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 60,
              ),
              child: IconButton(
                color: Colors.white,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    isCapturing = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            controller.value.isInitialized
                ? Center(
                    child: buildCameraPreview(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildCameraPreview() {
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                width: size,
                height: 300,
                child: CameraPreview(controller),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Prediction:\n',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
              Text(
                result,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
