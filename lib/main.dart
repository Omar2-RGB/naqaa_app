import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/habit_tracker_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/capsules_screen.dart';
// سنقوم بإنشاء هذه الملفات في الخطوات القادمة
 import 'screens/challenges_screen.dart';
import 'screens/about_developer_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://ocvtwtzqvuserldgtxpo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jdnR3dHpxdnVzZXJsZGd0eHBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjU0NDQ4NywiZXhwIjoyMTAyMTIwNDg3fQ.xY2V1XyEkzDKPaWpWC7dqqCtWTbdB-2hjrd6ehXRk3w',
  );

  runApp(const NaqaaApp());
}

final supabase = Supabase.instance.client;

class NaqaaApp extends StatelessWidget {
  const NaqaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نقاء', // تم تغيير الاسم إلى نقاء ✨
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4081),
          secondary: Color(0xFFB388FF),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AuthSplashScreen(), 
    );
  }
}

// ==========================================
// شاشة التحميل (إنشاء الحساب المخفي تلقائياً)
// ==========================================
class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen> {
  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = supabase.auth.currentSession;
    
    if (session == null) {
      try {
        await supabase.auth.signInAnonymously();
      } catch (e) {
        debugPrint('خطأ في تسجيل الدخول المخفي: $e');
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 80, color: Color(0xFFFF4081)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFFB388FF)),
            SizedBox(height: 10),
            Text('نجهز لكِ مساحتك النقية...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// الشاشة الرئيسية
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _dailyInspirations = [
    {'text': 'وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا', 'source': 'سورة الطور'},
    {'text': 'وَمَا كَانَ رَبُّكَ نَسِيًّا', 'source': 'سورة مريم'},
    {'text': 'لا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا', 'source': 'سورة التوبة'},
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'source': 'سورة الشرح'},
    {'text': 'الدُّنْيَا مَتَاعٌ، وَخَيْرُ مَتَاعِ الدُّنْيَا الْمَرْأَةُ الصَّالِحَةُ', 'source': 'حديث شريف (رواه مسلم)'},
    {'text': 'من لزم الاستغفار جعل الله له من كل هم فرجاً', 'source': 'حديث شريف'}
  ];

  late Map<String, String> _todaysInspiration;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _todaysInspiration = _dailyInspirations[random.nextInt(_dailyInspirations.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقاء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'مرحباً بكِ في مساحتك الآمنة 🌸',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 25),

              // الأيقونة السرية للوحة التحكم (تفتح بكلمة السر عند الضغط)
              GestureDetector(
                onTap: () {
                  _showPasswordDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E2C),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF4081).withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.spa, size: 80, color: Color(0xFFFF4081)),
                ),
              ),
              const SizedBox(height: 25),

              // بطاقة الإشراقة اليومية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB388FF).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFB388FF).withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text('إشراقة اليوم', style: TextStyle(color: Colors.amber[300], fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '"${_todaysInspiration['text']}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                      child: Text(_todaysInspiration['source']!, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // أزرار القائمة الرئيسية (تم تحديثها)
              _buildMainMenuButton(
                context,
                title: 'مكتبة الوعي',
                icon: Icons.menu_book,
                gradientColors: const [Color(0xFF42A5F5), Color(0xFF7E57C2)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ArticlesScreen())),
              ),
              const SizedBox(height: 15),
             _buildMainMenuButton(
  context,
  title: 'كبسولات الوعي',
  icon: Icons.lightbulb_outline,
  gradientColors: const [Color(0xFFFF9800), Color(0xFFFF5722)],
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CapsulesScreen())),
),
              const SizedBox(height: 15),
           _buildMainMenuButton(
  context,
  title: 'تحديات التغيير',
  icon: Icons.flag_outlined,
  gradientColors: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengesScreen())),
),// ... الكود السابق لزر متتبع العادات
              const SizedBox(height: 15),
              _buildMainMenuButton(
                context,
                title: 'متتبع العادات',
                icon: Icons.check_circle_outline,
                gradientColors: const [Color(0xFFFF4081), Color(0xFFB388FF)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HabitTrackerScreen())),
              ),
              
              const SizedBox(height: 30),
              const Divider(color: Colors.white24, indent: 30, endIndent: 30),
              const SizedBox(height: 15),
              
              // زر "عن المطور"
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutDeveloperScreen()));
                },
                icon: const Icon(Icons.code_rounded, color: Colors.grey),
                label: const Text('عن مُصمم التطبيق', style: TextStyle(color: Colors.grey, fontSize: 16)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
            
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('دخول الإدارة', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: passController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'أدخل كلمة السر',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passController.text == 'omarAziz1234@') {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمة السر خاطئة!')),
                );
              }
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenuButton(BuildContext context, {required String title, required IconData icon, required List<Color> gradientColors, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(color: gradientColors[1].withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}