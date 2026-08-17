import 'package:flutter/material.dart';
import '../main.dart'; // للوصول لـ supabase

class MyConsultationsScreen extends StatefulWidget {
  const MyConsultationsScreen({super.key});

  @override
  State<MyConsultationsScreen> createState() => _MyConsultationsScreenState();
}

class _MyConsultationsScreenState extends State<MyConsultationsScreen> {
  List<dynamic> _myConsultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyConsultations();
  }

  // جلب استشارات المستخدمة الحالية فقط من السحابة
  Future<void> _fetchMyConsultations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await supabase
          .from('consultations')
          .select()
          .eq('user_id', userId) // يجلب استشارات هذه البنت فقط بفضل حماية RLS
          .order('created_at', ascending: false);

      setState(() {
        _myConsultations = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب استشاراتي: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('استشاراتي والرد عليها 💙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF)))
          : _myConsultations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
                      const SizedBox(height: 15),
                      Text('لم تقومي بإرسال أي استشارة بعد', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _myConsultations.length,
                  itemBuilder: (context, index) {
                    final item = _myConsultations[index];
                    final bool isAnswered = item['is_answered'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAnswered ? Colors.green.withValues(alpha: 0.3) : const Color(0xFF00C6FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAnswered ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isAnswered ? 'تم الرد ✓' : 'قيد الانتظار ⏳',
                                  style: TextStyle(
                                    color: isAnswered ? Colors.greenAccent : Colors.orangeAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['message'] ?? '',
                            style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
                          ),
                          
                          // إذا قام المدير بالرد، سيظهر الرد هنا بأسلوب جميل
                          if (isAnswered && item['admin_reply'] != null) ...[
                            const SizedBox(height: 15),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C6FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFF00C6FF).withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.support_agent, color: Color(0xFF00C6FF), size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'رد الإدارة / المختص:',
                                        style: TextStyle(color: Color(0xFF00C6FF), fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['admin_reply'],
                                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}