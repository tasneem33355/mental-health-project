import 'package:flutter/material.dart';
import '../main.dart';
import 'article_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Map<String, String> _challengeStatuses = {
    'Hydration Goal': 'Start',
    'Gratitude Journal': 'Start',
  };

  void _handleChallengeClick(String title) {
    setState(() {
      if (_challengeStatuses[title] == 'Start') {
        _challengeStatuses[title] = 'Done';
      } else if (_challengeStatuses[title] == 'Done') {
        _challengeStatuses[title] = 'Finished';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Explore',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Psychoeducation Cards
            const Text(
              'Psychoeducation',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildEduCard(context, '🧠', 'What is Anxiety?', 'Understanding the fight or flight response', const Color(0xFFFF8C42), 
                    '''Anxiety is a natural emotional and physical response to stress, danger, or uncertainty. It is the body’s way of preparing itself to react in situations that may feel threatening or overwhelming. Everyone experiences anxiety at some point in life. It can happen before an important exam, a job interview, speaking in public, or facing a difficult situation. In small amounts, anxiety can actually be helpful because it keeps people alert, focused, and motivated. However, when anxiety becomes constant, intense, or difficult to control, it can start affecting daily life, relationships, sleep, and overall mental health.

One of the most important concepts related to anxiety is the “fight or flight” response. This is an automatic survival mechanism controlled by the nervous system. When the brain senses danger, it releases stress hormones such as adrenaline and cortisol. These hormones prepare the body to either face the danger (“fight”) or escape from it (“flight”). During this process, the heart beats faster, breathing becomes quicker, muscles tighten, and the mind becomes more alert. While this response was originally designed to protect humans from physical threats, modern anxiety is often triggered by emotional or psychological stress rather than actual danger.

People with anxiety may experience many emotional, mental, and physical symptoms. Emotionally, they may feel fear, nervousness, panic, or a constant sense of worry. Mentally, anxiety can cause overthinking, racing thoughts, difficulty concentrating, and expecting the worst outcomes in situations. Physically, anxiety may lead to sweating, shaking, dizziness, headaches, chest tightness, stomach problems, or trouble sleeping. Sometimes these symptoms can become so strong that people mistake anxiety attacks for serious medical emergencies.

There are different types of anxiety disorders. Generalized Anxiety Disorder (GAD) involves excessive and uncontrollable worrying about everyday life. Panic Disorder causes sudden panic attacks that can feel overwhelming and frightening. Social Anxiety Disorder involves intense fear of being judged or embarrassed in social situations. Phobias are strong fears related to specific objects or situations, such as heights, flying, or crowded spaces. Obsessive-Compulsive Disorder (OCD) and Post-Traumatic Stress Disorder (PTSD) are also closely connected to anxiety.

Anxiety can develop because of many factors. Genetics may play a role, meaning anxiety can sometimes run in families. Stressful life experiences, trauma, academic pressure, financial problems, social difficulties, or major life changes can also contribute to anxiety. In addition, lack of sleep, unhealthy habits, excessive caffeine, and constant exposure to stress can worsen symptoms over time.

Although anxiety can feel overwhelming, it is treatable and manageable. Healthy coping strategies include exercising regularly, maintaining good sleep habits, reducing stress, practicing deep breathing, meditation, journaling, and talking to trusted people. Therapy, especially Cognitive Behavioral Therapy (CBT), is highly effective in helping people understand and manage anxious thoughts. In some cases, medication may also help under professional supervision.

It is important to remember that having anxiety does not mean someone is weak or incapable. Mental health struggles are real and deserve understanding and support. Seeking help is a sign of strength, not weakness. With the right support, self-care, and treatment, people with anxiety can live healthy, successful, and fulfilling lives.'''),
                  _buildEduCard(context, '🌧️', 'Depression 101', 'Why do we feel sad without reason?', const Color(0xFF4A90D9),
                    '''Depression is more than simply feeling sad for a short period of time. It is a serious mental health condition that affects how a person thinks, feels, behaves, and experiences daily life. Everyone experiences sadness occasionally, especially after disappointment, loss, or stressful situations. However, depression lasts much longer and can deeply affect motivation, emotions, relationships, and physical health. A person with depression may feel emotionally empty, hopeless, or disconnected from life for weeks or even months.

One common question people ask is, “Why do we feel sad without a reason?” The truth is that depression does not always have a clear cause. Sometimes people experience depression because of painful life events such as trauma, grief, loneliness, stress, or failure. Other times, depression may develop because of biological or chemical changes in the brain. Hormones, neurotransmitters, genetics, and environmental factors can all influence mental health. This means a person can struggle with depression even when everything around them seems normal.

Depression affects emotions, thoughts, and physical well-being. Emotionally, people may feel sadness, emptiness, hopelessness, guilt, or irritability. Mentally, depression often causes negative thinking, loss of confidence, difficulty concentrating, and feelings of worthlessness. Physically, it can lead to tiredness, low energy, changes in appetite, body pain, headaches, or sleep problems. Some people sleep too much while others struggle with insomnia. Activities that once felt enjoyable may suddenly feel exhausting or meaningless.

There are several forms of depression. Major Depressive Disorder involves intense symptoms that interfere with daily life. Persistent Depressive Disorder is a long-lasting form of depression that may continue for years. Seasonal Affective Disorder (SAD) occurs during certain seasons, often in winter when sunlight exposure decreases. Postpartum depression affects some mothers after childbirth. Bipolar disorder also includes depressive episodes along with periods of extreme energy or mood elevation.

Depression can affect students, workers, parents, and people of all ages. Academic pressure, social isolation, financial struggles, family conflict, bullying, trauma, and unrealistic expectations can increase emotional stress. Social media can also contribute by creating unhealthy comparisons and pressure to appear happy or successful all the time. Many people hide their depression behind smiles because they fear judgment or misunderstanding from others.

One dangerous aspect of depression is that people may feel alone or believe nobody understands them. This can lead to withdrawing from friends and family. In severe cases, depression may cause thoughts of self-harm or suicide. Because of this, emotional support and early intervention are extremely important. Listening without judgment and encouraging professional help can make a huge difference in someone’s recovery.

Treatment for depression is possible, and recovery takes time and support. Therapy helps people understand their emotions and develop healthier coping strategies. Cognitive Behavioral Therapy (CBT) is one of the most effective approaches because it helps challenge negative thought patterns. Lifestyle changes such as regular exercise, healthy eating, sleep improvement, and social connection can also improve mental health. In some cases, antidepressant medications may help balance brain chemistry when prescribed by professionals.

Most importantly, people should understand that depression is not laziness or weakness. It is a real medical and psychological condition that deserves compassion and care. Talking openly about mental health helps reduce stigma and encourages people to seek help without shame. With support, treatment, and hope, people struggling with depression can heal and regain enjoyment in life.'''),
                  _buildEduCard(context, '⚡', 'Stress vs Burnout', 'How to tell the difference', const Color(0xFF9B6FFF),
                    '''Stress and burnout are closely connected, but they are not the same thing. Many people use the two terms interchangeably, yet understanding the difference is important for maintaining mental and physical health. Stress is usually a temporary response to pressure or challenges, while burnout is a deeper state of emotional, mental, and physical exhaustion caused by prolonged and unmanaged stress.

Stress is something everyone experiences. It can happen because of exams, deadlines, work pressure, financial problems, family responsibilities, or personal challenges. In small amounts, stress can actually improve performance by increasing focus and motivation. However, when stress becomes constant and overwhelming, it starts negatively affecting the body and mind. Common signs of stress include irritability, headaches, difficulty sleeping, muscle tension, anxiety, and feeling constantly pressured.

Burnout develops slowly over time when stress is ignored or continues for too long without enough rest or emotional recovery. Unlike stress, burnout often causes emotional numbness and a feeling of emptiness rather than panic or urgency. People experiencing burnout may feel physically exhausted, emotionally drained, detached from others, and unable to find motivation even for simple tasks. They may lose interest in activities they once enjoyed and begin feeling hopeless or emotionally disconnected from their work, studies, or relationships.

One major difference between stress and burnout is emotional intensity. Stress often feels like “too much” — too many tasks, too many worries, too much pressure. Burnout, on the other hand, feels like “not enough” — not enough energy, motivation, care, or emotional strength to continue. A stressed person may still believe they can regain control if things calm down, while a burned-out person often feels helpless and emotionally exhausted.

Students commonly experience both stress and burnout. Academic pressure, social expectations, lack of sleep, and fear of failure can create chronic stress. When students continuously push themselves without rest, self-care, or emotional support, burnout may occur. Signs of student burnout include loss of motivation to study, emotional exhaustion, procrastination, declining performance, isolation, and feeling mentally “shut down.”

Workplace burnout is also very common. Employees who work long hours, face constant pressure, or feel emotionally unsupported may gradually lose passion and productivity. Burnout can reduce concentration, creativity, and overall performance. It may also increase the risk of anxiety, depression, and physical health problems.

Preventing burnout requires more than simply taking short breaks. People need healthy balance in their lives. Proper sleep, exercise, relaxation, social connection, hobbies, and time away from responsibilities are essential for mental recovery. Learning to set boundaries and say “no” to excessive pressure is also important. Stress management techniques such as mindfulness, breathing exercises, journaling, and therapy can help reduce emotional overload before it becomes burnout.

If burnout has already developed, recovery may take time. Rest alone is sometimes not enough because burnout often affects emotional well-being and self-esteem. Support from friends, family, counselors, or mental health professionals can help individuals rebuild emotional energy and regain balance in life.

Understanding the difference between stress and burnout helps people recognize warning signs early. Stress is a signal that pressure is becoming too high, while burnout is a sign that the mind and body have been overwhelmed for too long. Taking care of mental health is not a luxury — it is necessary for living a healthy, balanced, and productive life.'''),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Daily Challenges
            const Text(
              'Daily Challenges',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildChallengeCard('💧', 'Hydration Goal', 'Drink 3 glasses of water before noon.', AppTheme.green),
            _buildChallengeCard('📝', 'Gratitude Journal', 'Write 2 things you are grateful for today.', AppTheme.accentPurple),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Widget _buildEduCard(BuildContext context, String emoji, String title, String subtitle, Color color, String content) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(
              title: title,
              content: content,
              emoji: emoji,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'edu-emoji-$title',
              child: Material(
                color: Colors.transparent,
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(String emoji, String title, String subtitle, Color iconColor) {
    String status = _challengeStatuses[title] ?? 'Start';
    String displayTitle = title;
    if (status == 'Done') {
      displayTitle = '$title (In Progress)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'Finished' ? AppTheme.green.withOpacity(0.3) : AppTheme.textDimmed.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: status == 'Finished' ? AppTheme.green : AppTheme.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: status == 'Finished' ? null : () => _handleChallengeClick(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Done' ? AppTheme.accentPurple : AppTheme.bgCardLight,
              disabledBackgroundColor: AppTheme.bgCard.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Done' ? Colors.white : (status == 'Finished' ? AppTheme.textDimmed : AppTheme.accentPurple),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
