import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:recipe_app/UI/chat/AudioRecorder.dart';
import 'package:recipe_app/UI/chat/MarkdownParser.dart';
import 'package:recipe_app/UI/chat/ResponseLoader.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';
import 'package:recipe_app/state/provider.dart';

class ChatBotForm extends StatefulWidget {
  const ChatBotForm({super.key});

  @override
  State<ChatBotForm> createState() => _ChatBotFormState();
}

class _ChatBotFormState extends State<ChatBotForm> {

  bool isOpen = false;
  bool isExpanded = false;
  bool isExpandedOptions = false;
  bool _isResponseLoading = false;

  @override
  Widget build(BuildContext context) {

    final sessionM = context.watch<StateProvider>().sessionMessages;

    
    return isOpen ?
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.only(top: 0, bottom: 15, left: 20, right: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AI chat', style: TextStyle(color: Colors.white)),
                    Row(
                      children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: Icon(Icons.expand)
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isOpen = false;
                          });
                        }, 
                        icon: Icon(Icons.close)
                      ),
                      ],
                    )
                  ]
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: index % 2 == 0 ? Alignment.topRight : Alignment.topLeft,
                            child: 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 55, 55, 55),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: sessionM[index].text != null 
                                      ? MarkdownParser(text: sessionM[index].text!) 
                                      : sessionM[index].data != null 
                                        ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(sessionM[index].data!["image"], height: 200, width: 200, fit: BoxFit.cover),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              sessionM[index].data!["text"], 
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: Colors.white
                                              )
                                            )
                                          ],
                                        )
                                        : sessionM[index].widget as Widget
                                  ),
                                  SizedBox(height: 20),
                                ],
                              )
                        );
                      },
                      itemCount: sessionM.length
                    ),
                  ),
                ),
              ChatInputField(isResponseLoading: _isResponseLoading),
            ],
          ),
        )
    :
    GestureDetector(
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: ChatButton(),
    );
  }
}

class ChatButton extends StatelessWidget {
  const ChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black)
        ),
        padding: EdgeInsets.all(10),
        child: Image.asset("assets/images/app-logo.png", fit: BoxFit.cover)
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  final bool isResponseLoading;
  const ChatInputField({super.key, required this.isResponseLoading});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool isExpandedOptions = false;
  File? _selectedImage;
  ParsedRecipe? recipe;
  void Function(SessionItem) addMessageToSession = (SessionItem message) {};
  void Function() removeLoaderFn = (){};
  void Function() clearSpeechResult = (){};
  late bool _isResponseLoading;


  @override
  void initState() {
    _isResponseLoading = widget.isResponseLoading;
    super.initState();
  }

  Future<File?> compressToFixedSize(File file, {int targetSizeKB = 512}) async {
  int quality = 90; // Start with high quality
  int step = 5; // Reduce quality in steps
  File? compressedFile;

  while (quality > 0) {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality, // Reduce quality dynamically
    );

    if (result == null) return null;

    // Check file size
    int sizeInKB = result.length ~/ 512;

    if (sizeInKB <= targetSizeKB) {
      // If file size is <= 1MB, save and return it
      compressedFile = File("${file.path}_compressed.jpg");
      await compressedFile.writeAsBytes(result);
      break;
    }

    quality -= step;
  }

  return compressedFile;
}

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          isExpandedOptions = false;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> toBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty || _selectedImage != null) {
      File? compressedImage;
      String messageText = _controller.text.trim();
        
        if(_selectedImage != null){
          compressedImage = await compressToFixedSize(_selectedImage!);
          String str = await toBase64(compressedImage!);
          print(str.length);
        }

        if(messageText != ''){
          _controller.clear();
        }
        
        if(compressedImage != null){
          setState(() {
            _selectedImage = null;
          });

          addMessageToSession(SessionItem(data: {"image": compressedImage, "text": messageText}));
        }else{
          print(messageText);
          addMessageToSession(SessionItem(text: messageText));
        }
        addMessageToSession(SessionItem(widget: ResponseLoader()));

        await http.post(
          Uri.parse('http://34.32.91.19:8000/generate'),
          headers: {
            "Content-Type": "application/json",
          },
          body: 
            compressedImage != null ? 
              jsonEncode(
                {
                  "image": await toBase64(compressedImage),
                  "input_text": _controller.text, 
                  "old_messages": jsonEncode([]), 
                  "recipe": jsonEncode(recipe!.toJson())
                }
              )

              :

              jsonEncode(
                {
                  "input_text": _controller.text, 
                  "old_messages": jsonEncode([]),
                  "recipe": jsonEncode(recipe!.toJson())
                }
              ),
        ).then((res) async => {
          removeLoaderFn(),
          addMessageToSession(SessionItem(text: jsonDecode(res.body)['answer'])),
          setState(() {
            clearSpeechResult();
            _isResponseLoading = false;
            _selectedImage = null;
          })
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = context.watch<StateProvider>();
    setState(() {
      if(stateProvider.speechResult.isNotEmpty){
        _controller.text = stateProvider.speechResult;
      };
      recipe = stateProvider.recipe;
      addMessageToSession = stateProvider.addSessionMessage;
      removeLoaderFn = stateProvider.removeLoader;
      clearSpeechResult = stateProvider.clearSpeechResult;
    });

    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 10),
      color: Colors.black,
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isExpandedOptions ? 100 : 0,
            child: isExpandedOptions
                ? Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      IconButton(
                        icon: Icon(Icons.image, color: Colors.white),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  )
                : SizedBox(),
          ),
          IconButton(
            icon: Icon(isExpandedOptions ? Icons.close : Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                isExpandedOptions = !isExpandedOptions;
              });
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImage != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, height: 50, width: 50, fit: BoxFit.cover),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(192, 0, 0, 0),
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Message",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          AudioRecorder(),
          IconButton(
            icon: Icon(Icons.send_rounded, color: _isResponseLoading ? Colors.white24 : Colors.white),
            onPressed: (){
              _isResponseLoading ? null : _sendMessage();
              setState(() {
                _isResponseLoading = true;
              });
            },
          ),
        ],
      ),
    );
  }
}