import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/providers/language_provider.dart';

class AppTranslations {
  static const Map<String, Map<AppLanguage, String>> _keys = {
    // App & Branding
    'app_name': {
      AppLanguage.english: 'Durga Puja Management',
      AppLanguage.bengali: 'দুর্গাপূজা ম্যানেজমেন্ট',
      AppLanguage.hindi: 'दुर्गा पूजा प्रबंधन',
      AppLanguage.odia: 'ଦୁର୍ଗା ପୂଜା ପରିଚାଳନା',
    },
    'app_tagline': {
      AppLanguage.english: 'Financial Management System',
      AppLanguage.bengali: 'অর্থনৈতিক পরিচালনা ব্যবস্থা',
      AppLanguage.hindi: 'वित्तीय प्रबंधन प्रणाली',
      AppLanguage.odia: 'ଆର୍ଥିକ ହିସାବ କିତାବ ପ୍ରଣାଳୀ',
    },

    // Navigation & Tabs
    'nav_dashboard': {
      AppLanguage.english: 'Dashboard',
      AppLanguage.bengali: 'ড্যাশবোর্ড',
      AppLanguage.hindi: 'डैशबोर्ड',
      AppLanguage.odia: 'ମୁଖ୍ୟ ହିସାବ',
    },
    'nav_collections': {
      AppLanguage.english: 'Collections',
      AppLanguage.bengali: 'চাঁদা সংগ্রহ',
      AppLanguage.hindi: 'चांदा संग्रह',
      AppLanguage.odia: 'ଚାନ୍ଦା ଆଦାୟ',
    },
    'nav_expenses': {
      AppLanguage.english: 'Expenses',
      AppLanguage.bengali: 'খরচ',
      AppLanguage.hindi: 'खर्च',
      AppLanguage.odia: 'ପୂଜା ଖର୍ଚ୍ଚ',
    },
    'nav_reports': {
      AppLanguage.english: 'Reports',
      AppLanguage.bengali: 'রিপোর্ট',
      AppLanguage.hindi: 'रिपोर्ट',
      AppLanguage.odia: 'ହିସାବ ରିପୋର୍ଟ',
    },
    'nav_settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.bengali: 'সেটিংস',
      AppLanguage.hindi: 'सेटिंग्स',
      AppLanguage.odia: 'ସେଟିଂସ',
    },

    // Common Actions
    'refresh': {
      AppLanguage.english: 'Refresh',
      AppLanguage.bengali: 'রিফ্রেশ',
      AppLanguage.hindi: 'रिफ्रेश',
      AppLanguage.odia: 'ପୁନର୍ବାର ଲୋଡ୍ କରନ୍ତୁ',
    },
    'app_reloaded': {
      AppLanguage.english: 'App reloaded completely fresh!',
      AppLanguage.bengali: 'অ্যাপ সম্পূর্ণ রিফ্রেশ হয়েছে!',
      AppLanguage.hindi: 'ऐप पूरी तरह से रिफ्रेश हो गया!',
      AppLanguage.odia: 'ଆପ୍ ସମ୍ପୂର୍ଣ୍ଣ ରିଫ୍ରେଶ୍ ହୋଇଗଲା!',
    },
    'sign_in': {
      AppLanguage.english: 'Sign In',
      AppLanguage.bengali: 'সাইন ইন',
      AppLanguage.hindi: 'साइन इन',
      AppLanguage.odia: 'ଲଗ୍ ଇନ୍ କରନ୍ତୁ',
    },
    'sign_out': {
      AppLanguage.english: 'Sign Out',
      AppLanguage.bengali: 'সাইন আউট',
      AppLanguage.hindi: 'সাইন আউট',
      AppLanguage.odia: 'ଲଗ୍ ଆଉଟ୍ କରନ୍ତୁ',
    },
    'email_address': {
      AppLanguage.english: 'Email Address',
      AppLanguage.bengali: 'ইমেইল অ্যাড্রেস',
      AppLanguage.hindi: 'ईमेल पता',
      AppLanguage.odia: 'ଇମେଲ୍ ଠିକଣା',
    },
    'password': {
      AppLanguage.english: 'Password',
      AppLanguage.bengali: 'পাসওয়ার্ড',
      AppLanguage.hindi: 'पासवर्ड',
      AppLanguage.odia: 'ପାସୱାର୍ଡ',
    },
    'remember_me': {
      AppLanguage.english: 'Remember Me',
      AppLanguage.bengali: 'মনে রাখুন',
      AppLanguage.hindi: 'याद रखें',
      AppLanguage.odia: 'ମନେ ରଖନ୍ତୁ',
    },

    // Dashboard & Stats
    'financial_summary': {
      AppLanguage.english: 'Financial Summary',
      AppLanguage.bengali: 'আর্থিক বিবরণী',
      AppLanguage.hindi: 'वित्तीय सारांश',
      AppLanguage.odia: 'ଆର୍ଥିକ ହିସାବ ସାରାଂଶ',
    },
    'total_collection': {
      AppLanguage.english: 'Total Collection',
      AppLanguage.bengali: 'মোট সংগ্রহ',
      AppLanguage.hindi: 'कुल चांदा',
      AppLanguage.odia: 'ମୋଟ ଆଦାୟ ଚାନ୍ଦା',
    },
    'total_expense': {
      AppLanguage.english: 'Total Expense',
      AppLanguage.bengali: 'মোট খরচ',
      AppLanguage.hindi: 'कुल खर्च',
      AppLanguage.odia: 'ମୋଟ ପୂଜା ଖର୍ଚ୍ଚ',
    },
    'net_balance': {
      AppLanguage.english: 'Net Balance',
      AppLanguage.bengali: 'অবশিষ্ট তহবিল',
      AppLanguage.hindi: 'कुल शेष राशि',
      AppLanguage.odia: 'ମୋଟ ବଳକା ଟଙ୍କା',
    },
    'pending_approvals': {
      AppLanguage.english: 'Pending Approvals',
      AppLanguage.bengali: 'অনুমোদনের অপেক্ষায়',
      AppLanguage.hindi: 'स्वीकृति के लिए लंबित',
      AppLanguage.odia: 'ଅନୁମୋଦନ ପାଇଁ ବାକି',
    },
    'quick_actions': {
      AppLanguage.english: 'Quick Actions',
      AppLanguage.bengali: 'দ্রুত কাজ',
      AppLanguage.hindi: 'त्वरित कार्य',
      AppLanguage.odia: 'ଦ୍ରୁତ କାର୍ଯ୍ୟ',
    },
    'add_collection': {
      AppLanguage.english: 'Add Collection',
      AppLanguage.bengali: 'চাঁদা যোগ করুন',
      AppLanguage.hindi: 'चांदा जोड़ें',
      AppLanguage.odia: 'ନୂଆ ଚାନ୍ଦା ଯୋଡନ୍ତୁ',
    },
    'add_expense': {
      AppLanguage.english: 'Add Expense',
      AppLanguage.bengali: 'খরচ যোগ করুন',
      AppLanguage.hindi: 'खर्च जोड़ें',
      AppLanguage.odia: 'ନୂଆ ଖର୍ଚ୍ଚ ଯୋଡନ୍ତୁ',
    },
    'recent_collections': {
      AppLanguage.english: 'Recent Collections',
      AppLanguage.bengali: 'সাম্প্রতিক সংগ্রহ',
      AppLanguage.hindi: 'हाल के चांदा संग्रह',
      AppLanguage.odia: 'ସମ୍ପ୍ରତି ଆଦାୟ ଚାନ୍ଦା',
    },

    // Collections & Receipts
    'receipt_preview': {
      AppLanguage.english: 'Donation Receipt Preview',
      AppLanguage.bengali: 'চাঁদার রসিদ প্রিভিউ',
      AppLanguage.hindi: 'चांदा रसीद पूर्वावलोकन',
      AppLanguage.odia: 'ଚାନ୍ଦା ରସିଦ୍ ପ୍ରିଭ୍ୟୁ',
    },
    'receipt_no': {
      AppLanguage.english: 'Receipt No',
      AppLanguage.bengali: 'রসিদ নম্বর',
      AppLanguage.hindi: 'रसीद संख्या',
      AppLanguage.odia: 'ରସିଦ୍ ସଂଖ୍ୟା',
    },
    'donor_name': {
      AppLanguage.english: 'Donor Name',
      AppLanguage.bengali: 'দাতার নাম',
      AppLanguage.hindi: 'दाता का नाम',
      AppLanguage.odia: 'ଚାନ୍ଦାଦାତାଙ୍କ ନାମ',
    },
    'mobile_number': {
      AppLanguage.english: 'Mobile Number',
      AppLanguage.bengali: 'মোবাইল নম্বর',
      AppLanguage.hindi: 'मोबाइल नंबर',
      AppLanguage.odia: 'ମୋବାଇଲ୍ ନମ୍ବର',
    },
    'amount': {
      AppLanguage.english: 'Amount',
      AppLanguage.bengali: 'পরিমাণ',
      AppLanguage.hindi: 'राशि',
      AppLanguage.odia: 'ରାଶି (ଟଙ୍କା)',
    },
    'payment_mode': {
      AppLanguage.english: 'Payment Mode',
      AppLanguage.bengali: 'পেমেন্ট মাধ্যম',
      AppLanguage.hindi: 'भुगतान का तरीका',
      AppLanguage.odia: 'ପେମେଣ୍ଟ୍ ମାଧ୍ୟମ',
    },
    'date': {
      AppLanguage.english: 'Date',
      AppLanguage.bengali: 'তারিখ',
      AppLanguage.hindi: 'तारीख',
      AppLanguage.odia: 'ତାରିଖ',
    },
    'share_whatsapp': {
      AppLanguage.english: 'Share on WhatsApp',
      AppLanguage.bengali: 'হোয়াটসঅ্যাপে শেয়ার করুন',
      AppLanguage.hindi: 'व्हाट्सएप पर शेयर करें',
      AppLanguage.odia: 'ହ୍ୱାଟସ୍‌ଆପ୍‌ରେ ପଠାନ୍ତୁ',
    },
    'thank_you_blessings': {
      AppLanguage.english: 'Thank you for your generous contribution to Durga Puja! May Goddess Durga bless you and your family.',
      AppLanguage.bengali: 'দুর্গাপূজায় আপনার মূল্যবান অনুদানের জন্য ধন্যবাদ! মা দুর্গা আপনাকে এবং আপনার পরিবারকে আশীর্বাদ করুন।',
      AppLanguage.hindi: 'दुर्गा पूजा में आपके अमूल्य योगदान के लिए धन्यवाद! मां दुर्गा आप और आपके परिवार को आशीर्वाद दें।',
      AppLanguage.odia: 'ଦୁର୍ଗା ପୂଜାରେ ଆପଣଙ୍କର ଅମୂଲ୍ୟ ଚାନ୍ଦା ଯୋଗଦାନ ପାଇଁ ହାର୍ଦ୍ଦିକ ଧନ୍ୟବାଦ! ମା\' ଦୁର୍ଗା ଆପଣଙ୍କୁ ଏବଂ ଆପଣଙ୍କ ପରିବାରକୁ ସୁଖ-ସମୃଦ୍ଧି ପ୍ରଦାନ କରନ୍ତୁ।',
    },

    // Reports Hub
    'reports_hub': {
      AppLanguage.english: 'Reports Hub',
      AppLanguage.bengali: 'রিপোর্ট হাব',
      AppLanguage.hindi: 'रिपोर्ट हब',
      AppLanguage.odia: 'ହିସାବ ପତ୍ର ରିପୋର୍ଟ',
    },
    'export_pdf': {
      AppLanguage.english: 'Export Itemized Financial PDF Report',
      AppLanguage.bengali: 'আর্থিক PDF রিপোর্ট ডাউনলোড করুন',
      AppLanguage.hindi: 'वित्तीय PDF रिपोर्ट डाउनलोड करें',
      AppLanguage.odia: 'ସମ୍ପୂର୍ଣ୍ଣ PDF ହିସାବ ଡାଉନଲୋଡ୍ କରନ୍ତୁ',
    },
    'export_excel': {
      AppLanguage.english: 'Export Collection & Expense Data (Excel .xlsx)',
      AppLanguage.bengali: 'এক্সেল ফাইল এক্সপোর্ট করুন (Excel .xlsx)',
      AppLanguage.hindi: 'एक्सेल फाइल डाउनलोड करें (Excel .xlsx)',
      AppLanguage.odia: 'ଏକ୍ସେଲ୍ (Excel .xlsx) ହିସାବ ଡାଉନଲୋଡ୍ କରନ୍ତୁ',
    },
    'export_csv': {
      AppLanguage.english: 'Export Raw Data (CSV)',
      AppLanguage.bengali: 'CSV ফাইল এক্সপোর্ট করুন',
      AppLanguage.hindi: 'CSV फाइल एक्सपोर्ट करें',
      AppLanguage.odia: 'CSV ଫାଇଲ୍ ଡାଉନଲୋଡ୍ କରନ୍ତୁ',
    },
    'category_expense_report': {
      AppLanguage.english: 'Category-wise Expense Details',
      AppLanguage.bengali: 'বিভাগীয় খরচ রিপোর্ট',
      AppLanguage.hindi: 'श्रेणी-वार खर्च रिपोर्ट',
      AppLanguage.odia: 'ବିଭାଗ ୱାରି ଖର୍ଚ୍ଚ ତାଲିକା',
    },
    'person_wise_collection': {
      AppLanguage.english: 'Person-wise Collection Report',
      AppLanguage.bengali: 'দাতার তালিকা ও সংগ্রহ রিপোর্ট',
      AppLanguage.hindi: 'दाता-वार संग्रह रिपोर्ट',
      AppLanguage.odia: 'ଚାନ୍ଦାଦାତା-ୱାରି ଆଦାୟ ତାଲିକା',
    },
    'collector_wise_collection': {
      AppLanguage.english: 'Collector-wise Collection Report',
      AppLanguage.bengali: 'সংগ্রাহক ভিত্তিক রিপোর্ট',
      AppLanguage.hindi: 'संग्रहकर्ता-वार रिपोर्ट',
      AppLanguage.odia: 'ସଂଗ୍ରାହକ-ୱାରି ଆଦାୟ ତାଲିକା',
    },
  };

  /// Fetch translation string by key and current language
  static String tr(String key, AppLanguage lang) {
    final map = _keys[key];
    if (map == null) return key;
    return map[lang] ?? map[AppLanguage.english] ?? key;
  }
}

/// Convenience extension method for WidgetRef
extension TranslationRefExtension on WidgetRef {
  String tr(String key) {
    final currentLang = watch(languageProvider);
    return AppTranslations.tr(key, currentLang);
  }
}
