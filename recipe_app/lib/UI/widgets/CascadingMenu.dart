import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/app_localizations.dart';
import 'package:recipe_app/state/provider.dart';

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

    final setLocale = context.watch<StateProvider>().setLocale;

    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white)
      ),

      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () {
            setLocale(Locale('en'));
          }, 
          child: Text(AppLocalizations.of(context)?.translate("english") ?? 'No locale')
        ),

        MenuItemButton(
          onPressed: () {
            setLocale(Locale('tr'));
          }, 
          child: Text(AppLocalizations.of(context)?.translate("turkish") ?? 'No locale')
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
