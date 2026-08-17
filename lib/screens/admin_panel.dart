import 'package:flutter/material.dart';
import '../main.dart'; // للوصول لـ supabase

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  // متغيرات تبويب الاستشارات
  List<dynamic> _consultations = [];
  
  // متغيرات تبويب نشر المقالات
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'إيمانيات';
  final List<String> _categories = ['إيمانيات', 'الصحة النفسية', 'تطوير الذات', 'الحماية الرقمية'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
  }

  // جلب الاستشارات من السحابة
  Future<void> _fetchConsultations() async {
    try {
      final data = await supabase
          .from('consultations')
          .select()
          .order('created_at', ascending: false);
      setState(() => _consultations = data);
    } catch (e) {
      debugPrint('خطأ في جلب الاستشارات: $e');
    }
  }

  // دالة الرد على الاستشارة
  Future<void> _replyConsultation(dynamic id, String reply) async {
    try {
      await supabase.from('consultations').update({
        'admin_reply': reply,
        'is_answered': true,
        'status': 'answered'
      }).eq('id', id);
      
      _fetchConsultations(); // تحديث القائمة بعد الرد
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الرد بنجاح! 💙')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الرد: $e')),
      );
    }
  }

  // دالة نشر مقال جديد في السحابة
  Future<void> _addArticle() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال العنوان والمحتوى للمقال')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String snippet = content.length > 50 ? '${content.substring(0, 50)}...' : content;

      await supabase.from('articles').insert({
        'title': title,
        'content': content,
        'category': _selectedCategory,
        'snippet': snippet,
      });

      if (!mounted) return;
      _titleController.clear();
      _contentController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر المقال في السحابة بنجاح! 🌟')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء النشر: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text('لوحة الإدارة والتحكم 🛠️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1E1E2C),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Color(0xFFFF4081),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF4081),
            tabs: [
              Tab(icon: Icon(Icons.favorite_outline), text: 'استشارات البنات'),
              Tab(icon: Icon(Icons.library_books_outlined), text: 'نشر مقال جديد'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ==========================================
            // التبويب الأول: صندوق الاستشارات والرد عليها
            // ==========================================
            _consultations.isEmpty
                ? const Center(
                    child: Text('لا توجد استشارات مرسلة حتى الآن', 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _consultations.length,
                    itemBuilder: (context, index) {
                      final item = _consultations[index];
                      final bool isAnswered = item['is_answered'] == true;
                      
                      return Card(
                        color: const Color(0xFF1E1E2C),
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] ?? 'بدون عنوان',
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
                                      isAnswered ? 'تم الرد' : 'قيد الانتظار',
                                      style: TextStyle(color: isAnswered ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['message'] ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                              ),
                              if (isAnswered && item['admin_reply'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'ردك: ${item['admin_reply']}',
                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showReplyDialog(item['id']),
                                  icon: const Icon(Icons.reply, size: 18),
                                  label: Text(isAnswered ? 'تعديل الرد' : 'الرد على الاستشارة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C6FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // ==========================================
            // التبويب الثاني: إضافة مقال جديد للمكتبة
            // ==========================================
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إضافة مقال جديد للمكتبة السحابية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),

                  // عنوان المقال
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'عنوان المقال',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E1E2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // اختيار التصنيف
                  const Text('اختر التصنيف:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1E1E2C),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // محتوى المقال
                  TextField(
                    controller: _contentController,
                    maxLines: 7,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                    decoration: InputDecoration(
                      labelText: 'محتوى المقال الكامل',
                      labelStyle: const TextStyle(color: Colors.grey),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: const Color(0xFF1E1E2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر النشر
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFB388FF)]),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addArticle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('نشر المقال للسحابة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة كتابة الرد
  void _showReplyDialog(dynamic id) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('الرد على الاستشارة', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: replyController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'اكتبي نصيحتك أو ردك هنا...',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                _replyConsultation(id, replyController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF)),
            child: const Text('إرسال الرد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}