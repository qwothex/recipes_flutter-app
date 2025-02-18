import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {

  final String text;

  const FilterButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        child: Text(
          text, 
          style: TextStyle(
            fontSize: 24,
            color: Colors.black
          ),
        ),
      ),
    );
  }
}