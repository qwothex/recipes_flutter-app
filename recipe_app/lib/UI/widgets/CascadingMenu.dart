import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyCascadingMenu extends StatefulWidget {
  const MyCascadingMenu({super.key});

  @override
  State<MyCascadingMenu> createState() => _MyCascadingMenuState();
}

class _MyCascadingMenuState extends State<MyCascadingMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white)
      ),

      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () {}, 
          style: ButtonStyle(
          ),
          child: const Text('Add Recipe')
        ),

        MenuItemButton(
          onPressed: () {}, 
          style: ButtonStyle(
          ),
          child: const Text('Setting')
        ),

        MenuItemButton(
          onPressed: () {}, 
          style: ButtonStyle(
          ),
          child: const Text('Send Feedback'), 
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          focusNode: _buttonFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: SvgPicture.asset(
            'assets/images/dots.svg', 
            width: 30, 
            height: 30,
          ),
        );
      },
    );
  }
}
