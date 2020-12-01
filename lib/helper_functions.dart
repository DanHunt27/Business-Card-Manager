import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:googleapis/language/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

Future getImage(bool camera) async {
  var image;
  if (camera) {
    image =
        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1000);
  } else {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: image.path,
    aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
    androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Your Card',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.ratio16x9,
        lockAspectRatio: false),
  );
  return croppedFile;
}

Future getCardInfo(File image) async {
  String name = '', company = '', phNum = '', website = '', comAddr = '';

  /*
   * --------------------------------------------------------------------------
   * Need to take out of file
   * --------------------------------------------------------------------------
   */
  final _credentials = new ServiceAccountCredentials.fromJson(r'''
    {
    }
  ''');
  const _SCOPES = const [LanguageApi.CloudLanguageScope];

  final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();
  final VisionText visionText = await textRecognizer.processImage(visionImage);

  RegExp PhoneNumReg = new RegExp(
    r"\(\d{3}\) \d{3}-\d{4}|\(\d{3}\)\d{3}-\d{4}|\d{10}|(\d{3}\.){2}\d{4}|(\d{3}-){2}\d{4}|(\d{3} ){2}\d{4}|\d{3}/\d{3}-\d{4}",
    caseSensitive: false,
    multiLine: false,
  );
  RegExp WebsiteReg = new RegExp(
    r"(www\.)?\w+\.[a-z]{3}",
    caseSensitive: false,
    multiLine: false,
  );

  for (TextBlock block in visionText.blocks) {
    for (TextLine line in block.lines) {
      if (PhoneNumReg.hasMatch(line.text)) {
        phNum = PhoneNumReg.stringMatch(line.text).toString();
        continue;
      }

      if (WebsiteReg.hasMatch(line.text)) {
        website = WebsiteReg.stringMatch(line.text).toString();
        continue;
      }

      Map<dynamic, dynamic> json = {
        "document": {
          'type': 'PLAIN_TEXT',
          'content': line.text,
        }
      };
      await clientViaServiceAccount(_credentials, _SCOPES)
          .then((http_client) async {
        AnalyzeEntitiesRequest request = AnalyzeEntitiesRequest.fromJson(json);
        var language = new LanguageApi(http_client);
        AnalyzeEntitiesResponse response =
            await language.documents.analyzeEntities(request);
        for (Entity entity in response.entities) {
          if (entity.type.contains('PERSON') && name == '') {
            name = entity.name;
          } else if (entity.type.contains('LOCATION')) {
            comAddr = entity.name;
          } else if (entity.type.contains('ORGANIZATION')) {
            company = entity.name;
          } else if (entity.type.contains('ADDRESS') && comAddr == '') {
            comAddr = entity.name;
          }
        }
      });
    }
  }
  return {
    'name': name,
    'company': company,
    'phNum': phNum,
    'website': website,
    'comAddr': comAddr
  };
}
