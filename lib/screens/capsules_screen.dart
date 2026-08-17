import 'package:flutter/material.dart';
import '../main.dart'; // للوصول لمتغير supabase

class CapsulesScreen extends StatefulWidget {
  const CapsulesScreen({super.key});

  @override
  State<CapsulesScreen> createState() => _CapsulesScreenState();
}

class _CapsulesScreenState extends State<CapsulesScreen> {
  List<Map<String, dynamic>> _capsules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCapsules();
  }

  // جلب الكبسولات من السحابة
 // جلب الكبسولات من السحابة وخلطها عشوائياً
  Future<void> _fetchCapsules() async {
    try {
      // جلب جميع الكبسولات بدون ترتيب محدد
      final data = await supabase.from('capsules').select();

      // تحويل البيانات إلى قائمة
      List<Map<String, dynamic>> shuffledCapsules = List<Map<String, dynamic>>.from(data);
      
      // السحر هنا 🪄: خلط الكبسولات عشوائياً في كل مرة تُفتح فيها الشاشة
      shuffledCapsules.shuffle(); 

      setState(() {
        _capsules = shuffledCapsules;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب الكبسولات: $e');
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // جعل شريط الأزرار شفافاً ليطفو فوق الكبسولة
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('كبسولات الوعي 💡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9800)))
          : _capsules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey[700]),
                      const SizedBox(height: 20),
                      Text('لا توجد كبسولات حالياً', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                    ],
                  ),
                )
              // استخدام PageView للتمرير العمودي (مثل الريلز)
              : PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _capsules.length,
                  itemBuilder: (context, index) {
                    final capsule = _capsules[index];
                    return _buildCapsuleCard(capsule);
                  },
                ),
    );
  }

  // تصميم البطاقة الفخمة لكل كبسولة
  Widget _buildCapsuleCard(Map<String, dynamic> capsule) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1E1E2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة ديكورية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF9800).withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.format_quote_rounded, size: 50, color: Color(0xFFFF9800)),
            ),
            const SizedBox(height: 40),
            
            // نص الكبسولة
            Text(
              capsule['content'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),

            // كاتب الكبسولة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "- ${capsule['author'] ?? 'فريق نقاء'} -",
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ),
            
            const Spacer(),
            
            // تلميح للتمرير للأعلى
            Column(
              children: [
                Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey[600], size: 30),
                Text('اسحبي للأعلى للمزيد', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}