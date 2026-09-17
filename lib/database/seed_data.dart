import 'article_dao.dart';
import 'skill_progress_dao.dart';
import '../models/article.dart';
import '../models/skill_progress.dart';
import '../models/skill_type.dart';

class SeedData {
  static final ArticleDao _articleDao = ArticleDao();
  static final SkillProgressDao _skillProgressDao = SkillProgressDao();

  static Future<void> seedIfEmpty() async {
    final count = await _articleDao.getArticleCount();
    if (count > 0) return; // Already has data

    final articles = _createSampleArticles();
    for (final article in articles) {
      final id = await _articleDao.createArticle(article);
      await _createRandomProgress(id);
    }
  }

  static List<Article> _createSampleArticles() {
    final now = DateTime.now();
    return [
      Article(
        title: 'The Future of Artificial Intelligence',
        content: '''Artificial intelligence is rapidly transforming our world.
From self-driving cars to virtual assistants, AI technologies are becoming an integral part of our daily lives.
Machine learning algorithms can now recognize images, translate languages, and even create art.
However, with these advancements come important ethical questions about privacy and job displacement.
Many experts believe that AI will create more jobs than it eliminates, but the transition may be challenging.
Education and reskilling programs will be crucial for workers in affected industries.
The key is to ensure that AI development benefits all of humanity, not just a select few.''',
        translatedContent: '人工智能正在快速改变我们的世界。从自动驾驶汽车到虚拟助手，AI技术正在成为我们日常生活中不可或缺的一部分。',
        url: 'https://example.com/ai-future',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Article(
        title: 'Learning English Through Music',
        content: '''Music is one of the most enjoyable ways to learn a new language.
Listening to English songs helps improve pronunciation and rhythm.
Many language learners find that singing along to their favorite songs builds confidence.
The repetitive nature of lyrics makes vocabulary easier to remember.
Pop songs often use everyday conversational English, making them practical for learners.
Try starting with slower songs and gradually move to faster ones.
Pay attention to how words are connected and which syllables are stressed.
Don't worry about understanding every word at first - focus on the overall meaning.''',
        translatedContent: '音乐是学习新语言最愉快的方式之一。听英文歌曲有助于改善发音和节奏感。',
        url: 'https://example.com/english-music',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Article(
        title: 'Healthy Eating Habits for Students',
        content: '''Good nutrition is essential for academic success.
Students who eat balanced meals tend to have better concentration and memory.
Breakfast is particularly important as it fuels your brain after a night of fasting.
Include protein-rich foods like eggs, yogurt, or nuts in your morning meal.
Whole grains provide sustained energy throughout the day.
Fruits and vegetables supply essential vitamins and minerals.
Stay hydrated by drinking plenty of water instead of sugary drinks.
Avoid excessive caffeine, especially in the afternoon, as it can disrupt sleep patterns.
Meal prepping on weekends can save time during busy school days.''',
        translatedContent: '良好的营养对学业成功至关重要。吃均衡饮食的学生通常有更好的注意力和记忆力。',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      Article(
        title: 'Climate Change and Its Effects',
        content: '''Climate change is one of the most pressing issues facing our planet today.
Global temperatures have risen significantly over the past century.
This warming trend is primarily caused by human activities, especially burning fossil fuels.
Rising temperatures lead to more frequent extreme weather events.
Sea levels are rising, threatening coastal communities around the world.
Many species are struggling to adapt to rapidly changing environments.
Transitioning to renewable energy sources is crucial for reducing carbon emissions.
Individual actions, such as reducing energy consumption and waste, can make a difference.
International cooperation is essential to address this global challenge effectively.''',
        translatedContent: '气候变化是当今地球面临的最紧迫的问题之一。全球气温在过去一个世纪里显著上升。',
        url: 'https://example.com/climate-change',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 18)),
      ),
      Article(
        title: 'The Benefits of Reading Books',
        content: '''Reading books offers numerous benefits for personal development.
It expands your vocabulary and improves your writing skills.
Fiction books help develop empathy by allowing you to experience different perspectives.
Non-fiction books provide knowledge about various subjects and current events.
Regular reading has been shown to reduce stress and improve sleep quality.
It strengthens brain connectivity and may help prevent cognitive decline.
Reading before bed is a great alternative to screen time.
Joining a book club can add a social element to your reading habit.
Set a goal to read at least one book per month to build consistency.
Don't be afraid to abandon a book that doesn't engage you - life is too short for boring books!''',
        translatedContent: '阅读书籍对个人发展有许多好处。它能扩展词汇量并提高写作技能。',
        url: 'https://example.com/reading-benefits',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 22)),
      ),
      Article(
        title: 'Travel Tips for First-Time Backpackers',
        content: '''Backpacking is an exciting way to explore the world on a budget.
Start by choosing a destination that matches your experience level.
Pack light - you'll thank yourself when walking long distances.
A good backpack should have padded straps and multiple compartments.
Always carry a basic first-aid kit and any necessary medications.
Research local customs and basic phrases in the native language.
Keep digital copies of important documents like your passport.
Stay in hostels to meet fellow travelers and save money.
Be open to changing your plans based on recommendations from locals.
Remember to take breaks and enjoy the journey, not just the destination.''',
        translatedContent: '背包旅行是一种令人兴奋的廉价探索世界的方式。首先选择一个与你经验水平相匹配的目的地。',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 28)),
      ),
    ];
  }

  static Future<void> _createRandomProgress(int articleId) async {
    final skills = SkillType.values;
    final random = DateTime.now().millisecondsSinceEpoch;

    // Randomly assign progress to some skills (not all)
    for (int i = 0; i < skills.length; i++) {
      // ~60% chance to have progress for each skill
      if ((random + i * 7) % 10 < 6) {
        final position = (random + i * 13) % 8; // Random line position 0-7
        await _skillProgressDao.updateLastLinePosition(
          articleId,
          skills[i],
          position,
        );
      }
    }
  }
}
