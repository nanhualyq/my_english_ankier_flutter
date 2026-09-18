import 'article_dao.dart';
import 'skill_progress_dao.dart';
import '../models/article.dart';
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
        translatedContent:
            '''人工智能正在快速改变我们的世界。\n从自动驾驶汽车到虚拟助手，AI技术正在成为我们日常生活中不可或缺的一部分。\n机器学习算法现在可以识别图像、翻译语言，甚至创作艺术作品。\n然而，随着这些进步，也出现了关于隐私和就业流失的重要伦理问题。\n许多专家认为，人工智能创造的就业岗位将超过其淘汰的岗位，但转型过程可能会很艰难。\n教育和再培训项目对受影响行业的工人至关重要。\n关键是确保人工智能的发展造福全人类，而不仅仅是少数人。''',
        url: 'https://example.com/ai-future',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Article(
        title: 'Learning English Through Music',
        content:
            '''Music is one of the most enjoyable ways to learn a new language.
Listening to English songs helps improve pronunciation and rhythm.
Many language learners find that singing along to their favorite songs builds confidence.
The repetitive nature of lyrics makes vocabulary easier to remember.
Pop songs often use everyday conversational English, making them practical for learners.
Try starting with slower songs and gradually move to faster ones.
Pay attention to how words are connected and which syllables are stressed.
Don't worry about understanding every word at first - focus on the overall meaning.''',
        translatedContent:
            '''音乐是学习新语言最愉快的方式之一。\n听英文歌曲有助于改善发音和节奏感。\n许多语言学习者发现，跟着喜欢的歌曲一起唱能建立自信心。\n歌词的重复性使词汇更容易记忆。\n流行歌曲通常使用日常会话英语，对学习者来说很实用。\n从较慢的歌曲开始，逐渐过渡到更快的歌曲。\n注意单词之间的连接方式以及重音落在哪些音节上。\n一开始不必担心理解每个单词——专注于整体意思即可。''',
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
        translatedContent:
            '''良好的营养对学业成功至关重要。\n吃均衡饮食的学生通常有更好的注意力和记忆力。\n早餐尤其重要，因为它在一夜禁食后为大脑提供能量。\n早餐中加入富含蛋白质的食物，如鸡蛋、酸奶或坚果。\n全谷物能在全天提供持续的能量。\n水果和蔬菜提供必需的维生素和矿物质。\n多喝水来保持水分，而不是喝含糖饮料。\n避免过量摄入咖啡因，尤其是在下午，因为它会干扰睡眠模式。\n在周末提前准备餐食可以节省忙碌上学日的时间。''',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      Article(
        title: 'Climate Change and Its Effects',
        content:
            '''Climate change is one of the most pressing issues facing our planet today.
Global temperatures have risen significantly over the past century.
This warming trend is primarily caused by human activities, especially burning fossil fuels.
Rising temperatures lead to more frequent extreme weather events.
Sea levels are rising, threatening coastal communities around the world.
Many species are struggling to adapt to rapidly changing environments.
Transitioning to renewable energy sources is crucial for reducing carbon emissions.
Individual actions, such as reducing energy consumption and waste, can make a difference.
International cooperation is essential to address this global challenge effectively.''',
        translatedContent:
            '''气候变化是当今地球面临的最紧迫的问题之一。\n全球气温在过去一个世纪里显著上升。\n这种变暖趋势主要是由人类活动造成的，尤其是燃烧化石燃料。\n气温上升导致极端天气事件更加频繁。\n海平面正在上升，威胁着世界各地的沿海社区。\n许多物种正在努力适应快速变化的环境。\n向可再生能源转型对减少碳排放至关重要。\n个人行动，如减少能源消耗和浪费，可以发挥作用。\n国际合作对于有效应对这一全球性挑战至关重要。''',
        url: 'https://example.com/climate-change',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 18)),
      ),
      Article(
        title: 'The Benefits of Reading Books',
        content:
            '''Reading books offers numerous benefits for personal development.
It expands your vocabulary and improves your writing skills.
Fiction books help develop empathy by allowing you to experience different perspectives.
Non-fiction books provide knowledge about various subjects and current events.
Regular reading has been shown to reduce stress and improve sleep quality.
It strengthens brain connectivity and may help prevent cognitive decline.
Reading before bed is a great alternative to screen time.
Joining a book club can add a social element to your reading habit.
Set a goal to read at least one book per month to build consistency.
Don't be afraid to abandon a book that doesn't engage you - life is too short for boring books!''',
        translatedContent:
            '''阅读书籍对个人发展有许多好处。\n它能扩展词汇量并提高写作技能。\n小说通过让你体验不同的视角来培养同理心。\n非小说类书籍提供关于各种主题和时事的知识。\n经常阅读已被证明可以减轻压力并改善睡眠质量。\n它能增强大脑连接，并可能有助于预防认知衰退。\n睡前阅读是屏幕时间的绝佳替代选择。\n加入读书会可以为你的阅读习惯增添社交元素。\n设定每月至少读一本书的目标以建立持续性。\n不要害怕放弃一本不吸引你的书——人生太短暂，不该浪费在无聊的书上！''',
        url: 'https://example.com/reading-benefits',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 22)),
      ),
      Article(
        title: 'Travel Tips for First-Time Backpackers',
        content:
            '''Backpacking is an exciting way to explore the world on a budget.
Start by choosing a destination that matches your experience level.
Pack light - you'll thank yourself when walking long distances.
A good backpack should have padded straps and multiple compartments.
Always carry a basic first-aid kit and any necessary medications.
Research local customs and basic phrases in the native language.
Keep digital copies of important documents like your passport.
Stay in hostels to meet fellow travelers and save money.
Be open to changing your plans based on recommendations from locals.
Remember to take breaks and enjoy the journey, not just the destination.''',
        translatedContent:
            '''背包旅行是一种令人兴奋的廉价探索世界的方式。\n首先选择一个与你经验水平相匹配的目的地。\n轻装出行——走长路时你会感谢自己的决定。\n一个好的背包应该有加厚肩带和多个隔层。\n始终携带基本的急救箱和必要的药物。\n研究当地风俗和当地语言的基本用语。\n保留护照等重要文件的电子副本。\n住旅馆可以认识其他旅行者并节省费用。\n根据当地人的建议，对计划保持开放态度。\n记得休息并享受旅程，而不仅仅是目的地。''',
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
