import os
import re

files = [
    r"c:\Users\User\Desktop\Projects\realty-app\lib\privacy_center_screen.dart",
    r"c:\Users\User\Desktop\Projects\realty-app\lib\help_and_support_screen.dart",
    r"c:\Users\User\Desktop\Projects\realty-app\lib\terms_and_conditions_screen.dart"
]

replacements = [
    (r"const Color\(0xFF1A1D1E\)", "Theme.of(context).colorScheme.onSurface"),
    (r"const Color\(0xFF5F6368\)", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"const Color\(0xFF4A85F6\)", "Theme.of(context).colorScheme.primary"),
    (r"const Color\(0xFFF2F6FF\)", "Theme.of(context).colorScheme.surface"),
    (r"Colors\.black87", "Theme.of(context).colorScheme.onSurface"),
    (r"Colors\.grey\[600\]", "Theme.of(context).colorScheme.onSurfaceVariant"),
    (r"Colors\.grey\[400\]", "Theme.of(context).colorScheme.outline"),
    (r"Colors\.grey\[500\]", "Theme.of(context).colorScheme.outline"),
]

for file_path in files:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    original = content
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    # Fix default params in privacy_center_screen.dart
    content = content.replace("Color titleColor = Theme.of(context).colorScheme.onSurface,", "Color? titleColor,")
    content = content.replace("Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant,", "Color? iconColor,")
    
    # Use ?? for the nullable colors in privacy_center_screen.dart where they are used
    content = content.replace("color: titleColor,", "color: titleColor ?? Theme.of(context).colorScheme.onSurface,")
    # Actually, in privacy_center_screen it is used as:
    # color: titleColor
    # color: iconColor
    content = content.replace("color: titleColor\n", "color: titleColor ?? Theme.of(context).colorScheme.onSurface\n")
    content = content.replace("color: iconColor\n", "color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant\n")
    # For iconColor inside Icon:
    content = content.replace("color: iconColor,", "color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,")

    if content != original:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated {file_path}")
