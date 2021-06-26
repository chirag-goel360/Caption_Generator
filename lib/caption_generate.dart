import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_caption_generator/live_caption.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  File _image;
  ImagePicker picker = ImagePicker();
  String result = "Fetching Response...";

  cameraImage() async {
    PickedFile image = await picker.getImage(
      source: ImageSource.camera,
    );
    if (image == null) {
      return null;
    }
    setState(() {
      _image = File(
        image.path,
      );
      isLoading = false;
    });
    fetchResponse(_image);
  }

  pickGalleryImage() async {
    PickedFile image = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return null;
    }
    setState(() {
      _image = File(
        image.path,
      );
      isLoading = false;
    });
    fetchResponse(_image);
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
    final requestImage = http.MultipartRequest(
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
    requestImage.fields['ext'] = mimeTypeData[1];
    requestImage.files.add(file);
    try {
      final steamResponse = await requestImage.send();
      final response = await http.Response.fromStream(
        steamResponse,
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

  void parseResponse(Map<String, dynamic> response) {
    String value = "";
    var predictions = response['predictions'];
    for (var prediction in predictions) {
      var caption = prediction['caption'];
      value += caption + "\n";
    }
    setState(() {
      result = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    BorderRadius borderRadius = BorderRadius.circular(6);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
        title: Text(
          'Caption Generator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.004,
                      1,
                    ],
                    colors: [
                      Colors.white24,
                      Colors.white54,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.5),
                      spreadRadius: 6,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: isLoading
                          ? Container(
                              child: Column(
                                children: [
                                  Text(
                                    'Captions Generator',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    'Image to Captions',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    width: 170,
                                    child: Image.asset(
                                      'assets/notepad.png',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return LiveCaption();
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: width - 200,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 17,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: borderRadius,
                                            ),
                                            child: Text(
                                              'Live Camera',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: pickGalleryImage,
                                          child: Container(
                                            width: width - 200,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 17,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade300,
                                              borderRadius: borderRadius,
                                            ),
                                            child: Text(
                                              'Gallery',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: cameraImage,
                                          child: Container(
                                            width: width - 200,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 17,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade400,
                                              borderRadius: borderRadius,
                                            ),
                                            child: Text(
                                              'Take a Photo',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          child: IconButton(
                                            onPressed: () {
                                              var val = "Fetching Response...";
                                              setState(() {
                                                isLoading = true;
                                                result = val;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              size: 30,
                                            ),
                                            color: Colors.black,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                          ),
                                        ),
                                        Container(
                                          width: width - 200,
                                          child: ClipRRect(
                                            borderRadius: borderRadius,
                                            child: Image.file(
                                              _image,
                                              height: 250,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: Text(
                                      '$result',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
