import 'package:flutter/material.dart';
import '../main.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Map<String, dynamic>> _challenges = [];
  Set<int> _completedChallengeIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final challengesData = await supabase.from('challenges').select().order('id', ascending: true);
      
      final userChallengesData = await supabase
          .from('user_challenges')
          .select('challenge_id')
          .eq('user_id', userId)
          .eq('is_completed', true);

      setState(() {
        _challenges = List<Map<String, dynamic>>.from(challengesData);
        _completedChallengeIds = userChallengesData.map<int>((row) => row['challenge_id'] as int).toSet();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب التحديات: $e');
      setState(() => _isLoading = false);
    }
  }

  // دالة الاحتفال عند الإنجاز (نافذة منبثقة فخمة)
  void _showCelebrationDialog(String title, String rewardText) {
    showDialog(
      context: context,
      builder: (context) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0.5, end: 1.0),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(color: Color(0xFF00B4DB), width: 2),
              ),
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة الكأس مع تأثير متوهج
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 70),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'أنجزتِ التحدي ببراعة! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    rewardText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4DB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('متابعة التحديات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleChallenge(int challengeId, bool isCurrentlyCompleted, String title, String rewardText) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      if (isCurrentlyCompleted) {
        _completedChallengeIds.remove(challengeId);
      } else {
        _completedChallengeIds.add(challengeId);
      }
    });

    try {
      if (isCurrentlyCompleted) {
        await supabase.from('user_challenges').delete().eq('user_id', userId).eq('challenge_id', challengeId);
      } else {
        await supabase.from('user_challenges').upsert({
          'user_id': userId,
          'challenge_id': challengeId,
          'is_completed': true
        });

        // إذا تم الإنجاز بنجاح، اعرض شاشة الاحتفال!
        if (mounted) {
          _showCelebrationDialog(title, rewardText);
        }
      }
    } catch (e) {
      debugPrint('خطأ في التحديث: $e');
      _fetchData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('تحديات التغيير 🎯', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4DB)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                final challengeId = challenge['id'] as int;
                final isCompleted = _completedChallengeIds.contains(challengeId);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFF1E1E2C).withValues(alpha: 0.5) : const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted ? Colors.green.withValues(alpha: 0.5) : const Color(0xFF00B4DB).withValues(alpha: 0.3),
                      width: isCompleted ? 2 : 1,
                    ),
                    boxShadow: isCompleted
                        ? [BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 2)]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              challenge['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.greenAccent : Colors.white,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        challenge['description'],
                        style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.6),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _toggleChallenge(challengeId, isCompleted, challenge['title'], challenge['reward_text']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted ? Colors.transparent : const Color(0xFF00B4DB),
                            elevation: isCompleted ? 0 : 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: isCompleted ? Colors.grey[700]! : Colors.transparent),
                            ),
                          ),
                          child: Text(
                            isCompleted ? 'تراجع عن الإنجاز' : 'أنجزت التحدي! 💪',
                            style: TextStyle(
                              color: isCompleted ? Colors.grey : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
}