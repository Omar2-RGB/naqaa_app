import 'package:flutter/material.dart';
import '../main.dart';
import 'favorite_articles_screen.dart'; // شاشة المفضلة سننئها فوراً

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Map<String, dynamic>> _articles = [];
  Set<int> _favoriteArticleIds = {}; // تخزين معرفات المقالات المفضلة للمستخدمة الحالية
  String _selectedCategory = 'الكل';
  bool _isLoading = true;

  final List<String> _categories = ['الكل', 'إيمانيات', 'الصحة النفسية', 'تطوير الذات', 'الحماية الرقمية'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _fetchFavorites();
    await _loadArticles();
  }

  // جلب المقالات المفضلة الخاصة بالمستخدمة الحالية من السحابة
  Future<void> _fetchFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await supabase
          .from('favorite_articles')
          .select('article_id')
          .eq('user_id', userId);

      setState(() {
        _favoriteArticleIds = Set<int>.from(data.map((e) => e['article_id'] as int));
      });
    } catch (e) {
      debugPrint('خطأ في جلب المفضلة: $e');
    }
  }

  // جلب المقالات من Supabase
  Future<void> _loadArticles() async {
    try {
      var query = supabase.from('articles').select();
      
      if (_selectedCategory != 'الكل') {
        query = query.eq('category', _selectedCategory);
      }

      final data = await query.order('created_at', ascending: false);

      setState(() {
        _articles = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب المقالات: $e');
      setState(() => _isLoading = false);
    }
  }

  // تبديل حالة المفضلة (إضافة / إزالة)
  Future<void> _toggleFavorite(int articleId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      if (_favoriteArticleIds.contains(articleId)) {
        _favoriteArticleIds.remove(articleId);
      } else {
        _favoriteArticleIds.add(articleId);
      }
    });

    try {
      if (_favoriteArticleIds.contains(articleId)) {
        // إضافة للمفضلة في السحابة
        await supabase.from('favorite_articles').insert({
          'user_id': userId,
          'article_id': articleId,
        });
      } else {
        // إزالة من المفضلة في السحابة
        await supabase.from('favorite_articles')
            .delete()
            .eq('user_id', userId)
            .eq('article_id', articleId);
      }
    } catch (e) {
      debugPrint('خطأ في تحديث المفضلة: $e');
      // إعادة الحالة القديمة في حال حدوث خطأ
      await _fetchFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('مكتبة الوعي السحابية 📚', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // زر الانتقال لشاشة المفضلة
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFFFF4081)),
            tooltip: 'المقالات المفضلة',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteArticlesScreen()),
              ).then((_) => _loadData()); // تحديث عند العودة
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // شريط التصنيفات
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    _loadArticles();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent : const Color(0xFF2A2D3E),
                      gradient: isSelected
                          ? const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFB388FF)])
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // قائمة المقالات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
                : _articles.isEmpty
                    ? Center(child: Text('لا توجد مقالات في هذا القسم حالياً', style: TextStyle(color: Colors.grey[600], fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          final int articleId = article['id'];
                          final bool isFav = _favoriteArticleIds.contains(articleId);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                              ).then((_) => _loadData());
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(article['category'] ?? 'عام', style: const TextStyle(color: Color(0xFFB388FF), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      // زر القلب (المفضلة)
                                      IconButton(
                                        icon: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? const Color(0xFFFF4081) : Colors.grey,
                                        ),
                                        onPressed: () => _toggleFavorite(articleId),
                                      ),
                                    ],
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
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Text('اقرئي المزيد', style: TextStyle(color: Color(0xFFFF4081), fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 5),
                                      Icon(Icons.arrow_forward_ios, size: 12, color: const Color(0xFFFF4081).withValues(alpha: 0.8)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// شاشة تفاصيل المقال (تبقى كما هي أو مع دعم القلب)
class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40, right: 30, left: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(article['category'] ?? '', style: const TextStyle(color: Color(0xFFFF4081), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article['title'] ?? '',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                article['content'] ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.white70, height: 1.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}