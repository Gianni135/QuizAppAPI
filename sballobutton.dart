import 'package:flutter/material.dart';

class SballoButton extends StatelessWidget {  const SballoButton({
    super.key,
    required this.text,
    required this.action,
    required this.bkColor,
    required this.fgColor,
    this.fontSize = 18,
    this.minFontSize = 10,
    this.maxFontSize = 18,
    this.verticalPadding = 12,
  });

  final String text;
  final Function() action;
  final Color bkColor;
  final Color fgColor;
  final double fontSize;
  final double minFontSize;
  final double maxFontSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    int textLength = text.length;
    // Più lungo è il testo, più piccolo sarà il font
    double adaptiveFontSize = maxFontSize;
    double adaptivePadding = verticalPadding;
      if (textLength > 25) {
      adaptiveFontSize = maxFontSize - ((textLength - 25) / 15).clamp(0, maxFontSize - minFontSize);
      adaptivePadding = verticalPadding - (textLength > 40 ? 6 : (textLength > 60 ? 8 : 0));
    }
    
    adaptiveFontSize = adaptiveFontSize.clamp(minFontSize, maxFontSize);
      return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 3), 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: adaptiveFontSize,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: bkColor,
          foregroundColor: fgColor,
          padding: EdgeInsets.symmetric(
            vertical: adaptivePadding,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          minimumSize: Size(88, 36),
        ),
        onPressed: action,
        child: Text(text, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
      ),
    );
  }
}
