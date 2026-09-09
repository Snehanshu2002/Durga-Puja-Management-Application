// Conditional import: uses dart:js_interop on web, no-op stub on other platforms.
export 'non_web_reload_stub.dart'
    if (dart.library.js_interop) 'web_reload_stub.dart';
