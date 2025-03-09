import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/state/provider.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  String? _filePath;
  Map<String, dynamic>? _textSpoken;
  bool _responseLoading = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _textSpoken = null;
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = "${directory.path}/audio_record.wav";
    
    await _recorder!.startRecorder(toFile: _filePath, codec: Codec.pcm16WAV);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
  await _recorder!.stopRecorder();
  setState(() {
    _isRecording = false;
    _responseLoading = true;
  });

  if (_filePath != null) {
    try {
      String base64Audio = await _convertToBase64(_filePath!);
      Map<String, dynamic> requestBody = {"audio_base64": base64Audio};

      await http.post(
        Uri.parse('http://34.32.91.19:8000/speech_to_text'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      ).then((res) => {
        setState(() {
          _textSpoken = jsonDecode(res.body);
          _responseLoading = false;
        })
      });

    } catch (e) {
      print("Exception: $e");
    }
  }
}

Future<String> _convertToBase64(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception("File does not exist: $filePath");
  }
  Uint8List bytes = await file.readAsBytes();
  return base64Encode(bytes); 
}


  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _textSpoken = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final stateProvider = context.read<StateProvider>().setSpeechResult;

    if(_textSpoken != null){
      Future.microtask(() => stateProvider(_textSpoken!))
      .then((res) => {
        setState(() {
          _textSpoken = null;
        })
      });
    }
    
    return 
      IconButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        icon: _isRecording 
          ? Icon(Icons.stop_circle) 
          : _responseLoading 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white),) 
            : Icon(Icons.mic),
        color: Colors.white,
      );
  }
}