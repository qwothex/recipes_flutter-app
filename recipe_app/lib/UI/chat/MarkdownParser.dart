import 'package:flutter/material.dart';

class MarkdownParser extends StatelessWidget {
  final String text;

  MarkdownParser({required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.white),
        children: parseMarkdown(cleanText(text)),
      ),
    );
  }

  String cleanText(String text) {
  return text
    // Normalize quotes
    .replaceAll("\u2019", "'")  // Unicode for ’
    .replaceAll("\u2018", "'")  // Unicode for ‘
    .replaceAll("\u201C", "\"") // Unicode for “
    .replaceAll("\u201D", "\"") // Unicode for ”
    // Normalize dashes
    .replaceAll("\u2014", "-")  // Unicode for —
    .replaceAll("\u2013", "-")  // Unicode for –
    .replaceAll("\uFFFD", "-") 
    .replaceAll(RegExp(r"\s-\s"), " - ");
}



  List<TextSpan> parseMarkdown(String text) {
  final List<TextSpan> spans = [];
  final List<String> lines = text.split('\n'); // Split by lines to detect lists

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i].trim();

    if (line.isEmpty) {
      continue; // Skip empty lines to prevent extra spacing
    }

    if (line.startsWith("* ")) {
      // ✅ This is a list item
      spans.add(const TextSpan(text: "• ", style: TextStyle(fontSize: 16, color: Colors.white))); // Bullet point
      line = line.replaceFirst("* ", ""); // Remove '*' from list items
    }

    spans.addAll(parseInlineMarkdown(line)); // Apply bold/italic inside the line

    // 🔹 Only add a newline if it's not the last line
    if (i < lines.length - 1) {
      spans.add(const TextSpan(text: "\n"));
    }
  }

  return spans;
}


  List<TextSpan> parseInlineMarkdown(String text) {
    final List<TextSpan> spans = [];

    // Regular expressions for inline Markdown styles (bold-italic first)
    final RegExp regex = RegExp(r'(\*\*\*(.*?)\*\*\*|\*\*(.*?)\*\*|\*(.*?)\*)');

    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: cleanText(text.substring(lastIndex, match.start)))); // Normal text
      }

      String matchedText = match.group(0)!;
      TextStyle? style;

      if (matchedText.startsWith("***") && matchedText.endsWith("***")) {
        style = const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
        matchedText = matchedText.substring(3, matchedText.length - 3).trim();
      } else if (matchedText.startsWith("**") && matchedText.endsWith("**")) {
        style = const TextStyle(fontWeight: FontWeight.bold);
        matchedText = matchedText.substring(2, matchedText.length - 2).trim();
      } else if (matchedText.startsWith("*") && matchedText.endsWith("*")) {
        style = const TextStyle(fontStyle: FontStyle.italic);
        matchedText = matchedText.substring(1, matchedText.length - 1).trim();
      }

      spans.add(TextSpan(text: cleanText(matchedText), style: style));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex))); // Remaining text
    }

    return spans;
  }
}