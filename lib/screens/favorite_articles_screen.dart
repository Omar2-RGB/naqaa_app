import 'package:flutter/material.dart';
import '../main.dart';
import 'articles_screen.dart'; // لعرض تفاصيل المقال عند الضغط عليه

class FavoriteArticlesScreen extends StatefulWidget {
  const FavoriteArticlesScreen({super.key});

  @override
  State<FavoriteArticlesScreen> createState() => _FavoriteArticlesScreenState();
}

class _FavoriteArticlesScreenState extends State<FavoriteArticlesScreen> {
  List<Map<String, dynamic>> _favoriteArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteArticles();
  }

  // جلب المقالات التي أعجبت بها المستخدمة الحالية فقط عبر ربط الجداول في Supabase
  Future<void> _fetchFavoriteArticles() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // استعلام جلب المفضلة مع تفاصيل المقالات المرتبطة بها
      final data = await supabase
          .from('favorite_articles')
          .select('articles(*)')
          .eq('user_id', userId);

      List<Map<String, dynamic>> loadedArticles = [];
      for (var item in data) {
        if (item['articles'] != null) {
          loadedArticles.add(Map<String, dynamic>.from(item['articles']));
        }
      }

      setState(() {
        _favoriteArticles = loadedArticles;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب المفضلة: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('المقالات المفضلة 🤍', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : _favoriteArticles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 70, color: Colors.grey),
                      const SizedBox(height: 15),
                      Text('لم تقومي بإضافة أي مقال للمفضلة بعد', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favoriteArticles.length,
                  itemBuilder: (context, index) {
                    final article = _favoriteArticles[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(article['category'] ?? '', style: const TextStyle(color: Color(0xFFB388FF), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              article['title'] ?? '',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              article['snippet'] ?? '',
                              style: TextStyle(fontSize: 14, color: Colors.grey[400], height: 1.5),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}