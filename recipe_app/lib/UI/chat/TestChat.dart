import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:recipe_app/UI/chat/AudioRecorder.dart';
import 'package:recipe_app/UI/widgets/RecipesList.dart';
import 'package:recipe_app/state/provider.dart';

class ChatBotForm extends StatefulWidget {
  const ChatBotForm({super.key});

  @override
  State<ChatBotForm> createState() => _ChatBotFormState();
}

class _ChatBotFormState extends State<ChatBotForm> {

  var isOpen = false;
  var isExpanded = false;
  var isExpandedOptions = false;

  @override
  Widget build(BuildContext context) {
    return isOpen ? Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? MediaQuery.of(context).size.height * 0.87 : MediaQuery.of(context).size.height * 0.6, //85
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                            isExpanded = false;
                          });
                        }, 
                        icon: Icon(Icons.close)
                      ),
                      ],
                    )
                  ]
                ),
                SizedBox(),
                Container(
                  child: Column(
                    children: [
                      Text(
                        "What can I help with?",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ChatOption(icon: Icons.image, text: "Create image", color: Colors.green),
                          ChatOption(icon: Icons.school, text: "Get advice", color: Colors.blue),
                          ChatOption(icon: Icons.article, text: "Summarize text", color: Colors.orange),
                          ChatOption(icon: Icons.code, text: "Code", color: Colors.purple),
                          ChatOption(icon: Icons.more_horiz, text: "More", color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ChatInputField(),
            ],
          ),
        ),
      ],
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
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            'AI',
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
        ),
      ),
    );
  }
}

class ChatOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const ChatOption({super.key, required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool isExpandedOptions = false;
  File? _selectedImage;
  ParsedRecipe? recipe;

  @override
  void initState() {
    _controller.text = "";
    super.initState();
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
        await http.post(
          Uri.parse('http://34.32.91.19:8000/generate'),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            _selectedImage != null ? 
              {
                "image": await toBase64(_selectedImage!),
                "input_text": _controller.text, 
                "old_messages": jsonEncode([]), 
                "recipe": jsonEncode(recipe!.toJson())
              }
            :
              {
                "input_text": _controller.text, 
                "old_messages": jsonEncode([]),
                "recipe": jsonEncode(recipe!.toJson())
              }
          ),
        ).then((res) => print(res.body));
      
      setState(() {
        _controller.clear();
        _selectedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = context.watch<StateProvider>();
    setState(() {
      _controller.text = stateProvider.speechResult;
      recipe = stateProvider.recipe;
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.black,
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isExpandedOptions ? 145 : 0,
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
                      IconButton(
                        icon: Icon(Icons.language, color: Colors.white),
                        onPressed: () {},
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
            icon: Icon(Icons.send_rounded, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}