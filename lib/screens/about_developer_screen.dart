import 'package:flutter/material.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('عن المطور 💻', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // خلفية متدرجة ولمسات ضوئية
         // خلفية متدرجة ولمسات ضوئية
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4DB).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4DB).withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // صورة المطور (أو أيقونة فخمة)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFFB388FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00B4DB).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFF1E1E2C),
                        child: Icon(Icons.code_rounded, size: 60, color: Colors.white),
                        // إذا كان لديك صورتك الشخصية أو شعارك الخاص، يمكنك استبدال Icon بـ:
                        // backgroundImage: AssetImage('assets/your_logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // الاسم والتخصص
                  const Text(
                    'م. عمر شعلان عبدالعزيز',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Software Engineer & UI/UX Designer',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400], letterSpacing: 1.2),
                  ),
                  
                  const SizedBox(height: 30),

                  // بطاقة النبذة التعريفية
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.format_quote_rounded, color: Color(0xFF00B4DB), size: 40),
                        SizedBox(height: 10),
                        Text(
                          'تم تصميم وتطوير تطبيق "نقاء" بحب وشغف، ليكون مساحة آمنة، نقية، ومُلهمة لكل فتاة تسعى لتطوير ذاتها والارتقاء بوعيها وروحانياتها. \n\nتم بناء التطبيق باستخدام أحدث تقنيات Flutter لضمان تجربة مستخدم سلسة وعصرية.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // أزرار التواصل أو استعراض الأعمال
                  const Text('تواصل معي', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(icon: Icons.language, color: Colors.blueAccent, label: 'موقعي'),
                      const SizedBox(width: 15),
                      _buildSocialButton(icon: Icons.code, color: Colors.grey, label: 'GitHub'),
                      const SizedBox(width: 15),
                      _buildSocialButton(icon: Icons.email_outlined, color: Colors.redAccent, label: 'راسلني'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  Text('Naqaa App © 2026', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ودجت صغيرة لأزرار التواصل
  Widget _buildSocialButton({required IconData icon, required Color color, required String label}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E2C),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: () {
              // هنا يمكنك لاحقاً إضافة روابط حقيقية باستخدام حزمة url_launcher
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}