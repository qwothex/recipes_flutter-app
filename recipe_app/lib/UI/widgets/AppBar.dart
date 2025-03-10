import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_app/UI/widgets/CascadingMenu.dart';
import 'package:recipe_app/app_localizations.dart';

AppBar appBar(bool backButton, String title, BuildContext context) {

    return AppBar(
      title: Text(AppLocalizations.of(context)?.translate(title) ?? 'No locale'),
      elevation: 0.0,
      centerTitle: true,
      leading: 
        backButton ?

        Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xfff7f8f8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            icon: SvgPicture.asset(
            'assets/images/arrow.svg',
            width: 30,
            height: 30,
          ),
          )
        ) : null,

      actions: [
        Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xfff7f8f8),
          borderRadius: BorderRadius.circular(10)
        ),
        child: MyCascadingMenu(),
        ),
      ],
    );
  }