// Web-specific page reload helper using dart:js_interop (Dart 3+)
import 'dart:js_interop';

@JS('window.location.reload')
external void _reload();

// Reloads the current page. Only called on Flutter Web.
void reloadPage() => _reload();
