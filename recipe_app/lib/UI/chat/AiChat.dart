import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool isOpen = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return isOpen ?
        
         AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 1,
          height: isExpanded 
            ? MediaQuery.of(context).size.height * 1 - 140 
            : MediaQuery.of(context).size.height * 0.5,
          color: Colors.black,
           child: Column(
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
                Expanded(
                  child: SizedBox.expand(
                    child: ChatBody(),
                  ),
                ),
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
      );
  }
}

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return 
        Container(
          color: Color.fromARGB(255, 157, 157, 157),
          child: Center(
            child: 
            Text("How can i help?", style: TextStyle(color: Colors.white))
          ),
        );
  }
}

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

      ]
    );
  }
}