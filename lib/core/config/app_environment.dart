enum Environment {
  dev,
  prod;

  static Environment fromString(String? value) {
    if (value?.toLowerCase() == 'prod' || value?.toLowerCase() == 'production') {
      return Environment.prod;
    }
    // Default to dev for safety if ENV is missing or invalid
    return Environment.dev;
  }
}

class AppEnvironment {
  // DEV Environment (Temporarily commented):
  // static bool get isDev => true;
  // static bool get isProd => false;
  // static String get name => 'DEV';

  // PROD Environment (Active):
  static bool get isDev => false;
  static bool get isProd => true;
  static String get name => 'PROD';
}
