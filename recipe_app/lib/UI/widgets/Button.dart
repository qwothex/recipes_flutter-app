import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {

  final String text;

  const FilterButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        child: Text(
          text, 
          style: TextStyle(
            fontSize: 19,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
          textAlign: TextAlign.center,
          textWidthBasis: TextWidthBasis.parent,
        ),
      ),
    );
  }
}