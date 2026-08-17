import 'package:flutter/material.dart';
import '../main.dart'; // للوصول لمتغير supabase

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  // جلب العادات من سحابة Supabase للمستخدمة الحالية فقط
  Future<void> _loadHabits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);

      setState(() {
        _habits = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب العادات من السحابة: $e');
      setState(() => _isLoading = false);
    }
  }

  // إضافة عادة جديدة للسحابة
  Future<void> _addHabit(String title, String date, String time, String period) async {
    if (title.trim().isEmpty) return;
    
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('habits').insert({
        'user_id': userId,
        'title': title.trim(),
        'isCompleted': 0,
        'habitDate': date,
        'habitTime': time,
        'period': period,
      });
      _loadHabits();
    } catch (e) {
      debugPrint('خطأ في إضافة العادة للسحابة: $e');
    }
  }

  // تحديث حالة إنجاز العادة في السحابة
  Future<void> _toggleHabit(dynamic id, int currentStatus) async {
    try {
      await supabase.from('habits').update({
        'isCompleted': currentStatus == 1 ? 0 : 1,
      }).eq('id', id);
      _loadHabits();
    } catch (e) {
      debugPrint('خطأ في تحديث العادة: $e');
    }
  }

  // حذف عادة من السحابة
  Future<void> _deleteHabit(dynamic id) async {
    try {
      await supabase.from('habits').delete().eq('id', id);
      _loadHabits();
    } catch (e) {
      debugPrint('خطأ في حذف العادة: $e');
    }
  }

  // النافذة السفلية الفخمة لإضافة العادة
  void _showAddHabitSheet() {
    final TextEditingController habitController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedPeriod = 'صباحاً'; // الافتراضي

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2C), // لون النافذة في الدارك مود
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إضافة عادة جديدة ✨',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                // حقل إدخال النص
                TextField(
                  controller: habitController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ما هي العادة؟ (مثال: شرب الماء)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: const Color(0xFF2A2D3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
                const SizedBox(height: 20),
                
                // اختيار الفترة (صباحاً / مساءً)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedPeriod = 'صباحاً'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedPeriod == 'صباحاً' ? Colors.orangeAccent.withValues(alpha: 0.2) : const Color(0xFF2A2D3E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: selectedPeriod == 'صباحاً' ? Colors.orangeAccent : Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('صباحاً ', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Icon(Icons.wb_sunny_rounded, color: selectedPeriod == 'صباحاً' ? Colors.orangeAccent : Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedPeriod = 'مساءً'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedPeriod == 'مساءً' ? Colors.indigoAccent.withValues(alpha: 0.2) : const Color(0xFF2A2D3E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: selectedPeriod == 'مساءً' ? Colors.indigoAccent : Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('مساءً ', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Icon(Icons.nightlight_round, color: selectedPeriod == 'مساءً' ? Colors.indigoAccent : Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // اختيار التاريخ والوقت
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        label: Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2D3E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setModalState(() => selectedDate = pickedDate);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.access_time, color: Colors.white, size: 18),
                        label: Text(selectedTime.format(context), style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2D3E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setModalState(() => selectedTime = pickedTime);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // زر الإضافة النهائي
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4081), Color(0xFFB388FF)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        String formattedDate = '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}';
                        String formattedTime = selectedTime.format(context);
                        _addHabit(habitController.text, formattedDate, formattedTime, selectedPeriod);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('أضيفي العادة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('عاداتي السحابية 🌱', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : _habits.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    final isCompleted = habit['isCompleted'] == 1;
                    final isMorning = habit['period'] == 'صباحاً';

                    return Dismissible(
                      key: Key(habit['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) => _deleteHabit(habit['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2A2D3E)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            habit['title'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey[600] : Colors.white,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(habit['habitDate'] ?? '', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                const SizedBox(width: 15),
                                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(habit['habitTime'] ?? '', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isMorning ? Colors.orangeAccent.withValues(alpha: 0.15) : Colors.indigoAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isMorning ? Colors.orangeAccent.withValues(alpha: 0.5) : Colors.indigoAccent.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round, 
                                          size: 12, color: isMorning ? Colors.orangeAccent : Colors.indigoAccent),
                                      const SizedBox(width: 4),
                                      Text(habit['period'] ?? '', 
                                          style: TextStyle(fontSize: 10, color: isMorning ? Colors.orangeAccent : Colors.indigoAccent)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          leading: GestureDetector(
                            onTap: () => _toggleHabit(habit['id'], habit['isCompleted']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isCompleted
                                    ? const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFB388FF)])
                                    : null,
                                border: isCompleted
                                    ? null
                                    : Border.all(color: Colors.grey[600]!, width: 2),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF4081), Color(0xFFB388FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66B388FF),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddHabitSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dark_mode, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 20),
          const Text(
            'لا توجد عادات مسجلة بعد',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            'نظّمي وقتك وأضيفي عاداتك بأسلوب احترافي!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}