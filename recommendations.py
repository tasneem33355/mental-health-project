"""
recommendations.py
==================
Bilingual (EN + AR) recommendation system.
Uses:
  - primary disease  (anxiety / depression / stress)
  - severity         (mild / moderate / severe) from DASS-42 scores
  - cause            (extracted from user text)
  - suicidal flag    (extracted from user text)
"""

import re

# ══════════════════════════════════════════════════════════════════════════════
# 1. SEVERITY FROM DASS-42 SCORES
# ══════════════════════════════════════════════════════════════════════════════
# DASS-42 official cutoffs (raw sum, not percentage)
DASS_CUTOFFS = {
    "depression": [(0, 9, "normal"), (10, 13, "mild"), (14, 20, "moderate"),
                   (21, 27, "severe"), (28, 999, "extremely_severe")],
    "anxiety":    [(0, 7, "normal"), (8, 9, "mild"),  (10, 14, "moderate"),
                   (15, 19, "severe"), (20, 999, "extremely_severe")],
    "stress":     [(0, 14, "normal"),(15, 18, "mild"),(19, 25, "moderate"),
                   (26, 33, "severe"), (34, 999, "extremely_severe")],
}

def get_severity(disease: str, raw_score: float, max_score: float = 1.0) -> str:
    """
    raw_score: إما نسبة (0-1) من الموديل، وإما raw DASS score
    بنحوّل النسبة لـ raw score تقريبي عشان نقدر نستخدم الـ cutoffs
    """
    # لو جاي من الموديل كنسبة (0-1)، نحوّله لـ raw score تقريبي
    if max_score == 1.0:
        # DASS-42 depression max=84, anxiety max=72, stress max=84
        max_raw = {"depression": 84, "anxiety": 72, "stress": 84}
        score = int(raw_score * max_raw.get(disease, 84))
    else:
        score = int(raw_score)

    for low, high, label in DASS_CUTOFFS.get(disease, []):
        if low <= score <= high:
            return label
    return "severe"


# ══════════════════════════════════════════════════════════════════════════════
# 2. CAUSE EXTRACTION FROM TEXT
# ══════════════════════════════════════════════════════════════════════════════
CAUSE_KEYWORDS = {
    "work": [
        "شغل", "عمل", "وظيفة", "مدير", "boss", "deadline", "مشروع", "project",
        "office", "مكتب", "راتب", "salary", "overtime", "job", "work", "career",
        "كثير شغل", "ضغط شغل", "مش قادر أكمل شغل", "tired from work",
    ],
    "relationships": [
        "حبيب", "حبيبة", "زوج", "زوجة", "جوز", "مراتي", "علاقة", "relationship",
        "أهل", "عيلة", "family", "صاحب", "صحاب", "friend", "خيانة", "betrayal",
        "فراق", "breakup", "طلاق", "divorce", "وحيد", "lonely", "خلاف", "conflict",
    ],
    "financial": [
        "فلوس", "مال", "money", "دين", "debt", "فقر", "مصاريف", "broke",
        "إيجار", "rent", "مديون", "financial", "بطالة", "unemployment",
    ],
    "academic": [
        "دراسة", "امتحان", "exam", "جامعة", "university", "مدرسة", "school",
        "درجات", "grades", "رسوب", "fail", "مذاكرة", "study", "تخرج",
    ],
    "health": [
        "مرض", "وجع", "pain", "صحة", "health", "doctor", "دكتور", "مستشفى",
        "hospital", "علاج", "treatment", "دواء", "medication", "نوم", "sleep",
    ],
    "social": [
        "ناس", "people", "مجتمع", "حكم", "judgment", "خجل", "shy", "منعزل",
        "isolated", "خايف", "scared", "مش قادر أتكلم", "can't talk",
    ],
    "self_worth": [
        "فاشل", "failure", "مش كافي", "not enough", "ضعيف", "weak", "worthless",
        "لا قيمة", "ما ينفعش", "مش عارف أنجح", "can't succeed", "loser",
    ],
    "trauma": [
        "صدمة", "trauma", "حادثة", "accident", "خسارة", "loss", "وفاة", "death",
        "مات", "died", "إساءة", "abuse", "كوابيس", "nightmares", "ذكريات",
    ],
}

def extract_cause(text: str) -> str:
    text_lower = text.lower()
    text_lower = re.sub(r'[^\w\s\u0600-\u06FF]', ' ', text_lower)
    scores = {}
    for cause, keywords in CAUSE_KEYWORDS.items():
        count = sum(1 for kw in keywords if kw.lower() in text_lower)
        if count > 0:
            scores[cause] = count
    if not scores:
        return "general"
    return max(scores, key=scores.get)


# ══════════════════════════════════════════════════════════════════════════════
# 3. SUICIDAL IDEATION DETECTION
# ══════════════════════════════════════════════════════════════════════════════
SUICIDAL_KEYWORDS = [
    "انتحار", "suicide", "أقتل نفسي", "kill myself", "أموت", "want to die",
    "عايز أموت", "مش عايز أعيش", "don't want to live", "نهاية حياتي",
    "end my life", "أريح نفسي", "rest forever", "مفيش فايدة من الحياة",
    "life is not worth", "أذي نفسي", "hurt myself", "إيذاء النفس",
    "self harm", "مش قادر أكمل", "can't go on", "عايز أختفي",
    "want to disappear", "لو مت", "if i die", "لو اختفيت",
]

def detect_suicidal(text: str) -> bool:
    text_lower = text.lower()
    return any(kw.lower() in text_lower for kw in SUICIDAL_KEYWORDS)


# ══════════════════════════════════════════════════════════════════════════════
# 4. RECOMMENDATIONS DATABASE (Bilingual)
# ══════════════════════════════════════════════════════════════════════════════

# Structure: disease → cause → severity_group → {tips, resources, referral}
# severity_group: "mild_moderate" | "severe"

REC_DB = {

    # ── ANXIETY ───────────────────────────────────────────────────────────────
    "anxiety": {
        "work": {
            "mild_moderate": {
                "tips_en": [
                    "Break your tasks into small steps and focus on one at a time",
                    "Take a 5-minute breathing break every hour",
                    "Communicate your workload clearly with your manager",
                    "Set clear boundaries between work time and rest time",
                ],
                "tips_ar": [
                    "قسّم مهامك لخطوات صغيرة وركز على خطوة واحدة في كل مرة",
                    "خذ استراحة تنفس 5 دقائق كل ساعة",
                    "تحدث بوضوح مع مديرك عن حجم عملك",
                    "حدد حدوداً واضحة بين وقت العمل والراحة",
                ],
                "resources_en": ["App: Calm or Headspace for quick work breaks",
                                  "Technique: 4-7-8 breathing (inhale 4s, hold 7s, exhale 8s)"],
                "resources_ar": ["تطبيق: Calm أو Headspace لفترات الراحة السريعة",
                                  "تقنية: التنفس 4-7-8 (استنشق 4 ثواني، احبس 7، اطرد 8)"],
                "referral_en": "If work anxiety persists for more than 2 weeks, consider speaking with a mental health professional.",
                "referral_ar": "لو قلق العمل مستمر أكثر من أسبوعين، فكّر في التحدث مع متخصص نفسي.",
            },
            "severe": {
                "tips_en": [
                    "Consider taking a short leave if possible — your mental health comes first",
                    "Talk to HR or a trusted colleague about your situation",
                    "Avoid making major work decisions when anxiety is high",
                ],
                "tips_ar": [
                    "فكّر في أخذ إجازة قصيرة لو ممكن — صحتك النفسية أولاً",
                    "تحدث مع قسم الموارد البشرية أو زميل موثوق عن وضعك",
                    "تجنب اتخاذ قرارات عمل كبيرة في وقت القلق الشديد",
                ],
                "resources_en": ["Cognitive Behavioral Therapy (CBT) is highly effective for work anxiety",
                                  "Book: 'Anxiety at Work' by Adrian Gostick"],
                "resources_ar": ["العلاج المعرفي السلوكي (CBT) فعّال جداً لقلق العمل",
                                  "كتاب: 'Anxiety at Work' لـ Adrian Gostick"],
                "referral_en": "Severe work-related anxiety requires professional support. Please consult a therapist or psychiatrist.",
                "referral_ar": "قلق العمل الشديد يحتاج دعماً متخصصاً. من فضلك استشر معالجاً نفسياً أو طبيباً نفسياً.",
            },
        },
        "relationships": {
            "mild_moderate": {
                "tips_en": [
                    "Express your feelings calmly using 'I feel...' statements",
                    "Set healthy boundaries in your relationships",
                    "Don't try to solve everything at once",
                ],
                "tips_ar": [
                    "عبّر عن مشاعرك بهدوء باستخدام عبارات 'أنا أشعر...'",
                    "حدد حدوداً صحية في علاقاتك",
                    "لا تحاول حل كل شيء دفعة واحدة",
                ],
                "resources_en": ["Book: 'Attached' by Amir Levine — understanding relationship patterns",
                                  "Couples or individual counseling can help significantly"],
                "resources_ar": ["كتاب: 'Attached' لـ Amir Levine — لفهم أنماط العلاقات",
                                  "الإرشاد الفردي أو للأزواج بيساعد كتير"],
                "referral_en": "If relationship anxiety is affecting your sleep or daily function, a therapist can help.",
                "referral_ar": "لو قلق العلاقات بيأثر على نومك أو حياتك اليومية، معالج نفسي يقدر يساعد.",
            },
            "severe": {
                "tips_en": [
                    "Create some distance if the relationship is causing constant distress",
                    "Reach out to a trusted family member or friend for support",
                    "Journaling your feelings daily can help process the anxiety",
                ],
                "tips_ar": [
                    "خلق مسافة مؤقتة لو العلاقة بتسبب ضيقاً مستمراً",
                    "تواصل مع فرد من العائلة أو صديق موثوق للدعم",
                    "كتابة مشاعرك يومياً في دفتر بيساعد على معالجة القلق",
                ],
                "resources_en": ["CBT or DBT therapy is recommended for severe relationship anxiety"],
                "resources_ar": ["العلاج المعرفي السلوكي أو DBT موصى به لقلق العلاقات الشديد"],
                "referral_en": "Please consult a mental health professional. Severe relationship anxiety is treatable.",
                "referral_ar": "من فضلك استشر متخصصاً نفسياً. قلق العلاقات الشديد قابل للعلاج.",
            },
        },
        "general": {
            "mild_moderate": {
                "tips_en": [
                    "Practice 4-7-8 breathing daily",
                    "Reduce caffeine intake — it worsens anxiety",
                    "Exercise for at least 20 minutes a day",
                    "Limit news and social media consumption",
                ],
                "tips_ar": [
                    "مارس تنفس 4-7-8 يومياً",
                    "قلل الكافيين — بيزيد القلق",
                    "مارس الرياضة 20 دقيقة على الأقل يومياً",
                    "قلل استهلاك الأخبار ووسائل التواصل الاجتماعي",
                ],
                "resources_en": ["App: Calm or Insight Timer",
                                  "Book: 'Dare' by Barry McDonagh",
                                  "YouTube: Progressive Muscle Relaxation guided sessions"],
                "resources_ar": ["تطبيق: Calm أو Insight Timer",
                                  "كتاب: 'Dare' لـ Barry McDonagh",
                                  "YouTube: جلسات Progressive Muscle Relaxation موجّهة"],
                "referral_en": "If anxiety persists for more than 2 weeks, consider speaking with a professional.",
                "referral_ar": "لو القلق مستمر أكثر من أسبوعين، فكّر في التحدث مع متخصص.",
            },
            "severe": {
                "tips_en": [
                    "Do not isolate yourself — stay connected with safe people",
                    "Try grounding: name 5 things you see, 4 you hear, 3 you touch",
                    "Avoid making big decisions when anxiety peaks",
                ],
                "tips_ar": [
                    "لا تعزل نفسك — ابقَ على تواصل مع الناس الآمنين",
                    "جرب تقنية التأريض: اذكر 5 أشياء تراها، 4 تسمعها، 3 تلمسها",
                    "تجنب اتخاذ قرارات كبيرة في وقت ذروة القلق",
                ],
                "resources_en": ["CBT is the gold standard for severe anxiety",
                                  "Medication may help — consult a psychiatrist"],
                "resources_ar": ["CBT هو المعيار الذهبي لعلاج القلق الشديد",
                                  "الدواء قد يساعد — استشر طبيباً نفسياً"],
                "referral_en": "Severe anxiety requires professional treatment. Please reach out to a therapist or psychiatrist soon.",
                "referral_ar": "القلق الشديد يحتاج علاجاً متخصصاً. من فضلك تواصل مع معالج نفسي أو طبيب نفسي في أقرب وقت.",
            },
        },
    },

    # ── DEPRESSION ────────────────────────────────────────────────────────────
    "depression": {
        "work": {
            "mild_moderate": {
                "tips_en": [
                    "Try to find one small meaningful task at work each day",
                    "Take short walks outside during your lunch break",
                    "Talk to a trusted colleague — connection helps",
                ],
                "tips_ar": [
                    "حاول تلاقي مهمة صغيرة ذات معنى في العمل كل يوم",
                    "اخرج في نزهة قصيرة أثناء استراحة الغداء",
                    "تحدث مع زميل موثوق — التواصل بيساعد",
                ],
                "resources_en": ["Book: 'Lost Connections' by Johann Hari",
                                  "Technique: Behavioral Activation — schedule small enjoyable activities"],
                "resources_ar": ["كتاب: 'Lost Connections' لـ Johann Hari",
                                  "تقنية: التنشيط السلوكي — جدوّل أنشطة صغيرة ممتعة"],
                "referral_en": "Work-related depression responds well to therapy. Consider reaching out to a professional.",
                "referral_ar": "الاكتئاب المرتبط بالعمل يستجيب جيداً للعلاج. فكّر في التواصل مع متخصص.",
            },
            "severe": {
                "tips_en": [
                    "Take medical leave if possible — you need recovery time",
                    "Maintain a basic daily routine even if it feels hard",
                    "Tell one trusted person how you truly feel",
                ],
                "tips_ar": [
                    "خذ إجازة طبية لو ممكن — تحتاج وقتاً للتعافي",
                    "حافظ على روتين يومي أساسي حتى لو صعب",
                    "أخبر شخصاً موثوقاً واحداً بمشاعرك الحقيقية",
                ],
                "resources_en": ["Antidepressants combined with therapy show strong results",
                                  "Contact a psychiatrist as soon as possible"],
                "resources_ar": ["مضادات الاكتئاب مع العلاج النفسي بتعطي نتائج قوية",
                                  "تواصل مع طبيب نفسي في أقرب وقت ممكن"],
                "referral_en": "Severe depression is a medical condition. Please see a psychiatrist urgently.",
                "referral_ar": "الاكتئاب الشديد حالة طبية. من فضلك راجع طبيباً نفسياً بشكل عاجل.",
            },
        },
        "self_worth": {
            "mild_moderate": {
                "tips_en": [
                    "Write 3 things you did well today — no matter how small",
                    "The critical voice in your head is not the truth",
                    "Treat yourself with the same kindness you'd give a friend",
                ],
                "tips_ar": [
                    "اكتب 3 أشياء قمت بها بشكل جيد اليوم — مهما كانت صغيرة",
                    "الصوت الناقد في رأسك ليس الحقيقة",
                    "تعامل مع نفسك بنفس اللطف الذي تعطيه لصديق",
                ],
                "resources_en": ["Book: 'Feeling Good' by David Burns",
                                  "Book: 'Self-Compassion' by Kristin Neff"],
                "resources_ar": ["كتاب: 'Feeling Good' لـ David Burns",
                                  "كتاب: 'Self-Compassion' لـ Kristin Neff"],
                "referral_en": "Low self-worth with depression responds very well to CBT therapy.",
                "referral_ar": "ضعف الثقة مع الاكتئاب يستجيب جيداً جداً للعلاج المعرفي السلوكي.",
            },
            "severe": {
                "tips_en": [
                    "You are not your worst thoughts — please reach out for help",
                    "Start with one tiny act of self-care today",
                    "Connect with someone safe right now",
                ],
                "tips_ar": [
                    "أنت لست أفكارك السيئة — من فضلك اطلب المساعدة",
                    "ابدأ بفعل صغير جداً من الرعاية الذاتية اليوم",
                    "تواصل مع شخص آمن الآن",
                ],
                "resources_en": ["Urgent: Please contact a mental health professional",
                                  "CBT and medication together are very effective"],
                "resources_ar": ["عاجل: من فضلك تواصل مع متخصص نفسي",
                                  "العلاج المعرفي السلوكي والدواء معاً فعّالان جداً"],
                "referral_en": "Please seek professional help immediately. You deserve support and recovery.",
                "referral_ar": "من فضلك اطلب مساعدة متخصصة فوراً. أنت تستحق الدعم والتعافي.",
            },
        },
        "general": {
            "mild_moderate": {
                "tips_en": [
                    "Maintain a consistent daily routine",
                    "Get 15 minutes of sunlight every day — it genuinely helps",
                    "Light exercise (a 30-minute walk) is clinically proven to reduce mild depression",
                    "Connect with at least one person daily",
                ],
                "tips_ar": [
                    "حافظ على روتين يومي ثابت",
                    "احصل على 15 دقيقة من أشعة الشمس كل يوم — بيساعد فعلاً",
                    "الرياضة الخفيفة (مشي 30 دقيقة) ثبت علمياً إنها بتقلل الاكتئاب الخفيف",
                    "تواصل مع شخص واحد على الأقل يومياً",
                ],
                "resources_en": ["App: Woebot for daily mental health support",
                                  "Book: 'The Depression Cure' by Stephen Ilardi",
                                  "Book: 'Feeling Good' by David Burns"],
                "resources_ar": ["تطبيق: Woebot للدعم النفسي اليومي",
                                  "كتاب: 'The Depression Cure' لـ Stephen Ilardi",
                                  "كتاب: 'Feeling Good' لـ David Burns"],
                "referral_en": "If symptoms persist more than 2 weeks, please speak with a doctor or therapist.",
                "referral_ar": "لو الأعراض مستمرة أكثر من أسبوعين، من فضلك تحدث مع طبيب أو معالج.",
            },
            "severe": {
                "tips_en": [
                    "Do not be alone — stay with safe people",
                    "Focus only on the next hour, not the whole day",
                    "Even getting out of bed is an achievement today",
                ],
                "tips_ar": [
                    "لا تكن وحدك — ابقَ مع أشخاص آمنين",
                    "ركز على الساعة القادمة فقط، ليس اليوم كله",
                    "حتى النهوض من السرير إنجاز اليوم",
                ],
                "resources_en": ["Combination of therapy and medication is most effective for severe depression",
                                  "Please contact a psychiatrist as soon as possible"],
                "resources_ar": ["مزيج العلاج النفسي والدواء هو الأكثر فعالية للاكتئاب الشديد",
                                  "من فضلك تواصل مع طبيب نفسي في أقرب وقت ممكن"],
                "referral_en": "Severe depression is a serious medical condition. Please seek help urgently.",
                "referral_ar": "الاكتئاب الشديد حالة طبية خطيرة. من فضلك اطلب المساعدة بشكل عاجل.",
            },
        },
    },

    # ── STRESS ────────────────────────────────────────────────────────────────
    "stress": {
        "work": {
            "mild_moderate": {
                "tips_en": [
                    "Use the Pomodoro technique: 25 min work + 5 min break",
                    "Write your top 3 priorities each morning and stick to them",
                    "Learn to say no to extra tasks when overloaded",
                    "Disconnect from work emails after working hours",
                ],
                "tips_ar": [
                    "استخدم تقنية Pomodoro: 25 دقيقة عمل + 5 دقائق راحة",
                    "اكتب أهم 3 أولويات كل صباح والتزم بها",
                    "تعلّم قول 'لا' للمهام الإضافية عند الضغط الزائد",
                    "افصل نفسك عن إيميلات العمل بعد ساعات العمل",
                ],
                "resources_en": ["App: Todoist or Notion for task management",
                                  "Book: 'Deep Work' by Cal Newport"],
                "resources_ar": ["تطبيق: Todoist أو Notion لإدارة المهام",
                                  "كتاب: 'Deep Work' لـ Cal Newport"],
                "referral_en": "If work stress is causing physical symptoms, consult a doctor.",
                "referral_ar": "لو ضغط العمل بيسبب أعراضاً جسمانية، استشر طبيباً.",
            },
            "severe": {
                "tips_en": [
                    "You may be experiencing burnout — this is a real medical condition",
                    "Take urgent time off if possible",
                    "Talk to your manager or HR about workload redistribution",
                ],
                "tips_ar": [
                    "قد تكون تعاني من الإرهاق الوظيفي (Burnout) — وهذه حالة طبية حقيقية",
                    "خذ إجازة عاجلة لو ممكن",
                    "تحدث مع مديرك أو الموارد البشرية عن إعادة توزيع عبء العمل",
                ],
                "resources_en": ["Book: 'Burnout' by Emily Nagoski",
                                  "Urgent: Consult an occupational health specialist"],
                "resources_ar": ["كتاب: 'Burnout' لـ Emily Nagoski",
                                  "عاجل: استشر أخصائي الصحة المهنية"],
                "referral_en": "Severe burnout requires professional support. Please consult a doctor or therapist.",
                "referral_ar": "الإرهاق الوظيفي الشديد يحتاج دعماً متخصصاً. من فضلك استشر طبيباً أو معالجاً.",
            },
        },
        "academic": {
            "mild_moderate": {
                "tips_en": [
                    "Plan your study schedule in advance — avoid last-minute cramming",
                    "Use Active Recall and Spaced Repetition for effective studying",
                    "Sleep is more valuable than all-nighters before exams",
                ],
                "tips_ar": [
                    "خطط جدول مذاكرتك مسبقاً — تجنب الدراسة في اللحظة الأخيرة",
                    "استخدم Active Recall وSpaced Repetition للمذاكرة الفعّالة",
                    "النوم أهم من السهر قبل الامتحانات",
                ],
                "resources_en": ["App: Anki for Spaced Repetition",
                                  "App: Forest to block distractions while studying"],
                "resources_ar": ["تطبيق: Anki لـ Spaced Repetition",
                                  "تطبيق: Forest لمنع التشتيت أثناء المذاكرة"],
                "referral_en": "If academic stress is severely impacting you, talk to your university counselor.",
                "referral_ar": "لو ضغط الدراسة بيأثر عليك بشكل كبير، تحدث مع المرشد الأكاديمي في جامعتك.",
            },
            "severe": {
                "tips_en": [
                    "Your worth is not defined by your grades",
                    "Talk to your academic advisor — they can offer real solutions",
                    "Seek your university's mental health support services",
                ],
                "tips_ar": [
                    "قيمتك لا تُحدّد بدرجاتك",
                    "تحدث مع مرشدك الأكاديمي — بيقدر يقدم حلولاً حقيقية",
                    "اطلب خدمات الدعم النفسي في جامعتك",
                ],
                "resources_en": ["Most universities offer free mental health counseling"],
                "resources_ar": ["معظم الجامعات تقدم إرشاداً نفسياً مجانياً"],
                "referral_en": "Please reach out to a counselor or therapist. Academic stress at this level needs support.",
                "referral_ar": "من فضلك تواصل مع مرشد أو معالج. ضغط الدراسة بهذا المستوى يحتاج دعماً.",
            },
        },
        "general": {
            "mild_moderate": {
                "tips_en": [
                    "Exercise for 20 minutes daily — it reduces cortisol significantly",
                    "Write your thoughts in a daily journal",
                    "Focus on what you can control, let go of what you can't",
                    "Schedule genuine rest time — it's not wasted time",
                ],
                "tips_ar": [
                    "مارس الرياضة 20 دقيقة يومياً — بيقلل الكورتيزول بشكل ملحوظ",
                    "اكتب أفكارك في دفتر يومي",
                    "ركز على ما تقدر تتحكم فيه، واترك ما لا تقدر",
                    "جدوّل وقت راحة حقيقي — هو مش وقت ضائع",
                ],
                "resources_en": ["App: Insight Timer for short meditation sessions",
                                  "Book: 'The Stress Solution' by Rangan Chatterjee",
                                  "Technique: Progressive Muscle Relaxation before sleep"],
                "resources_ar": ["تطبيق: Insight Timer لجلسات تأمل قصيرة",
                                  "كتاب: 'The Stress Solution' لـ Rangan Chatterjee",
                                  "تقنية: Progressive Muscle Relaxation قبل النوم"],
                "referral_en": "Chronic stress (over 1 month) is worth discussing with a professional.",
                "referral_ar": "الضغط المزمن (أكثر من شهر) يستحق التحدث عنه مع متخصص.",
            },
            "severe": {
                "tips_en": [
                    "Your body is sending serious signals — please listen to them",
                    "Eliminate one major stressor if possible",
                    "Ask for help — carrying everything alone is not sustainable",
                ],
                "tips_ar": [
                    "جسمك يرسل إشارات خطيرة — من فضلك استمع إليها",
                    "أزل مصدر ضغط رئيسي واحد لو ممكن",
                    "اطلب المساعدة — حمل كل شيء وحدك ليس مستداماً",
                ],
                "resources_en": ["Severe chronic stress can cause physical illness — see a doctor",
                                  "Therapy (CBT or mindfulness-based) is highly effective"],
                "resources_ar": ["الضغط المزمن الشديد قد يسبب أمراضاً جسدية — راجع طبيباً",
                                  "العلاج النفسي (CBT أو القائم على اليقظة الذهنية) فعّال جداً"],
                "referral_en": "Please consult a doctor or therapist. Severe stress at this level needs professional attention.",
                "referral_ar": "من فضلك استشر طبيباً أو معالجاً. الضغط الشديد بهذا المستوى يحتاج اهتماماً متخصصاً.",
            },
        },
    },
}

# Suicidal crisis — overrides everything
SUICIDAL_REC = {
    "tips_en": [
        "You are not alone — help is available right now",
        "Please reach out to someone you trust immediately",
        "Remove access to any means of self-harm if possible",
        "Stay with another person — do not be alone right now",
    ],
    "tips_ar": [
        "أنت لست وحدك — المساعدة متاحة الآن",
        "من فضلك تواصل مع شخص تثق به فوراً",
        "ابتعد عن أي وسيلة قد تؤذي بها نفسك",
        "ابقَ مع شخص آخر — لا تكن وحدك الآن",
    ],
    "resources_en": [
        "🆘 International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/",
        "🆘 Crisis Text Line (US): Text HOME to 741741",
        "🆘 Befrienders Worldwide: https://www.befrienders.org",
    ],
    "resources_ar": [
        "🆘 الرابطة الدولية للوقاية من الانتحار: https://www.iasp.info/resources/Crisis_Centres/",
        "🆘 خط أزمات إيميج (مصر): 08008880700",
        "🆘 خط مساندة (السعودية): 920033360",
        "🆘 موقع Befrienders العالمي: https://www.befrienders.org",
    ],
    "referral_en": "🚨 URGENT: Please contact a mental health crisis line or go to the nearest emergency room immediately. Your life has value and help is available.",
    "referral_ar": "🚨 عاجل جداً: من فضلك تواصل مع خط أزمات الصحة النفسية أو اذهب لأقرب طوارئ فوراً. حياتك لها قيمة والمساعدة متاحة.",
}


# ══════════════════════════════════════════════════════════════════════════════
# 5. MAIN FUNCTION
# ══════════════════════════════════════════════════════════════════════════════

def get_recommendations(
    disease: str,
    disease_score: float,
    user_text: str,
) -> dict:
    """
    disease      : 'anxiety' | 'depression' | 'stress'
    disease_score: float 0-1 من الموديل
    user_text    : النص الذي كتبه المستخدم
    returns      : dict بالتوصيات الكاملة
    """
    is_suicidal = detect_suicidal(user_text)
    if is_suicidal:
        return {
            "suicidal_flag": True,
            "severity": "crisis",
            "cause": "crisis",
            **SUICIDAL_REC,
        }

    severity = get_severity(disease, disease_score)
    severity_group = "severe" if severity in ("severe", "extremely_severe") else "mild_moderate"
    cause = extract_cause(user_text)

    disease_db = REC_DB.get(disease, REC_DB["stress"])
    cause_db   = disease_db.get(cause, disease_db.get("general", {}))
    rec        = cause_db.get(severity_group, cause_db.get("mild_moderate", {}))

    return {
        "suicidal_flag": False,
        "severity": severity,
        "cause": cause,
        "tips_en": rec.get("tips_en", []),
        "tips_ar": rec.get("tips_ar", []),
        "resources_en": rec.get("resources_en", []),
        "resources_ar": rec.get("resources_ar", []),
        "referral_en": rec.get("referral_en", ""),
        "referral_ar": rec.get("referral_ar", ""),
    }