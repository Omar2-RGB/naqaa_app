import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // تغيير الاسم إلى v4 ليتم إنشاء القاعدة وإضافة المقالات الجديدة
    _database = await _initDB('awareness_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        habitDate TEXT,
        habitTime TEXT,
        period TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        snippet TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // إضافة المقالات (شاملة الجانب الديني والتوعوي)
  Future<void> seedArticles() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM articles'));
    
    if (count == 0) {
      List<Map<String, dynamic>> dummyArticles = [
        // المقالات الدينية 
        {
          'title': 'الحجاب.. تاج العفة والجمال',
          'snippet': 'الحجاب ليس مجرد غطاء، بل هو هوية وقيمة وستر يبرز جمال روحك.',
          'content': 'فرض الله الحجاب حمايةً وتكريماً لكِ. إنه ليس عائقاً أمام طموحاتك أو نجاحاتك، بل هو إعلان عن هويتك الإسلامية واعتزازك بدينك وأمر ربك. تذكري دائماً أن جمال المرأة الحقيقي ينبع من حيائها وعفتها، وأن رضا الله هو أسمى غاية. كوني فخورة بحجابك فهو تاجك الذي يميزكِ.',
          'category': 'إيمانيات',
        },
        {
          'title': 'العلاقات المحرمة.. أوهام وحقائق',
          'snippet': 'احمي قلبك ودينك من خطوات الشيطان، وتعرفي على خطر العلاقات العاطفية المحرمة.',
          'content': 'الإسلام يحمي قلب المرأة وكرامتها، ولذلك حرّم العلاقات العاطفية خارج إطار الزواج الشرعي. هذه العلاقات غالباً ما تبدأ بخطوات بسيطة ومحادثات بدافع "الزمالة أو الصداقة"، ويزينها الشيطان، لكنها تنتهي باستنزاف المشاعر، القلق، وغضب الله. احفظي قلبك لمن يستحقه ويطرق باب بيتك بالحلال، فالحب الحقيقي هو الذي يبدأ برضا الله وينتهي تحته ظله.',
          'category': 'إيمانيات',
        },
        {
          'title': 'الصلاة.. راحتكِ وملاذكِ',
          'snippet': 'الصلاة ليست مجرد حركات، بل هي لقاء مباشر مع الله يمنحك الطمأنينة.',
          'content': 'الصلاة هي عماد الدين، وأول ما نُسأل عنه يوم القيامة. في زحمة الحياة، الدراسة، ومشاكل اليوم، تعتبر الصلاة المحطة التي تستريحين فيها وتفرغين همومك بين يدي الله. حافظي دائماً عليها في وقتها مهما كنتِ مشغولة، وتذكري قول النبي ﷺ: "أرحنا بها يا بلال". الصلاة هي الحبل الذي يربطك بالله فلا تقطعيه.',
          'category': 'إيمانيات',
        },
        // المقالات الأخرى
        {
          'title': 'كيف تبنين ثقتك بنفسك؟',
          'snippet': 'خطوات عملية بسيطة لتعزيز ثقتك وبناء شخصية قوية.',
          'content': 'الثقة بالنفس ليست شيئاً نولد به، بل هي مهارة نكتسبها بالممارسة. ابدئي بتقبل عيوبك قبل ميزاتك، ولا تقارني نفسك بالآخرين على وسائل التواصل الاجتماعي...',
          'category': 'تطوير الذات',
        },
        {
          'title': 'الحماية من الابتزاز الإلكتروني',
          'snippet': 'دليلك الشامل لحماية بياناتك وصورك على الإنترنت.',
          'content': 'الإنترنت عالم واسع ومفيد، لكنه يحتاج لحذر. لا تشاركي صورك الخاصة أبداً، وتأكدي من تفعيل التحقق بخطوتين. إذا تعرضتِ لأي تهديد، لا تصمتي وأبلغي أهلك فوراً.',
          'category': 'الحماية الرقمية',
        }
      ];

      for (var article in dummyArticles) {
        await db.insert('articles', article);
      }
    }
  }
}