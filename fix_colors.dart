import 'dart:io';

void main() {
  var files = [
    r"c:\Users\User\Desktop\Projects\realty-app\lib\privacy_center_screen.dart",
    r"c:\Users\User\Desktop\Projects\realty-app\lib\help_and_support_screen.dart",
    r"c:\Users\User\Desktop\Projects\realty-app\lib\terms_and_conditions_screen.dart"
  ];

  var replacements = {
    r"const Color\(0xFF1A1D1E\)": "Theme.of(context).colorScheme.onSurface",
    r"const Color\(0xFF5F6368\)": "Theme.of(context).colorScheme.onSurfaceVariant",
    r"const Color\(0xFF4A85F6\)": "Theme.of(context).colorScheme.primary",
    r"const Color\(0xFFF2F6FF\)": "Theme.of(context).colorScheme.surface",
    r"Colors\.black87": "Theme.of(context).colorScheme.onSurface",
    r"Colors\.grey\[600\]": "Theme.of(context).colorScheme.onSurfaceVariant",
    r"Colors\.grey\[400\]": "Theme.of(context).colorScheme.outline",
    r"Colors\.grey\[500\]": "Theme.of(context).colorScheme.outline",
  };

  for (var filePath in files) {
    var file = File(filePath);
    var content = file.readAsStringSync();
    var original = content;

    replacements.forEach((pattern, replacement) {
      content = content.replaceAll(RegExp(pattern), replacement);
    });

    content = content.replaceAll("Color titleColor = Theme.of(context).colorScheme.onSurface,", "Color? titleColor,");
    content = content.replaceAll("Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant,", "Color? iconColor,");

    content = content.replaceAll("color: titleColor,", "color: titleColor ?? Theme.of(context).colorScheme.onSurface,");
    content = content.replaceAll("color: iconColor,", "color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,");

    content = content.replaceAll("color: titleColor\n", "color: titleColor ?? Theme.of(context).colorScheme.onSurface\n");
    content = content.replaceAll("color: iconColor\n", "color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant\n");

    if (content != original) {
      file.writeAsStringSync(content);
      print("Updated $filePath");
    }
  }
}
