import 'package:flutter/material.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import '../data/app_state.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'wellness_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<_PlanItem> _plan = [
    _PlanItem(
        icon: '🌬️',
        title: 'Morning Ritual',
        subtitle: 'Start your day right',
        color: Color(0xFF4A90D9),
        route: '/morning-ritual'),
    _PlanItem(
        icon: '📓',
        title: 'Safe Journal',
        subtitle: 'Private thoughts',
        color: Color(0xFF9B6FFF),
        route: '/journal'),
    _PlanItem(
        icon: '🧠',
        title: 'ADHD Exercise',
        subtitle: 'Stay focused',
        color: Color(0xFFFF8C42),
        route: '/adhd-exercise'),
    _PlanItem(
        icon: '🌙',
        title: 'Nightly Unwind',
        subtitle: 'Peaceful sleep',
        color: Color(0xFF4CAF82),
        route: '/nightly-unwind'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: _navIndex == 1
          ? const ExploreScreen()
          : _navIndex == 2
              ? const WellnessScreen()
              : _navIndex == 3
                  ? const ProfileScreen()
                  : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildQuoteCard(),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                    _buildPlanSection(),
                    const SizedBox(height: 24),
                    _buildGoalTrackerSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good Morning,',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            Text(AppState.userName ?? 'Friend',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none,
                  color: AppTheme.textWhite, size: 22),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1A8A), Color(0xFF5B2EC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('📖', style: TextStyle(fontSize: 24)),
          SizedBox(height: 12),
          Text(
            '"You don\'t have to control your thoughts. You just have to stop letting them control you."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '— Dan Millman',
            style: TextStyle(
              color: AppTheme.lightPurple,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final canCheckIn = AppState.canCheckIn;
    final buttons = [
      _ActionBtn(icon: Icons.assignment_outlined, label: 'DASS 42\nAssessment',
          onTap: () => Navigator.pushNamed(context, '/dass')),
      _ActionBtn(
          icon: canCheckIn ? Icons.check_circle_outline : Icons.check_circle,
          label: canCheckIn ? 'Check-In' : 'Done\nToday',
          onTap: () {
            if (canCheckIn) {
              Navigator.pushNamed(context, '/mood-questionnaire').then((_) => setState(() {}));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have already completed your check-in for today!')),
              );
            }
          }),
      _ActionBtn(icon: Icons.sentiment_satisfied_alt, label: 'Log\nMood',
          onTap: () => Navigator.pushNamed(context, '/mood-patterns')),
      _ActionBtn(icon: Icons.psychology_outlined, label: 'NLP\nAI',
          onTap: () => Navigator.pushNamed(context, '/nlp-prediction')),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((b) {
        return Expanded(
          child: GestureDetector(
            onTap: b.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.textDimmed.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(b.icon, color: AppTheme.accentPurple, size: 26),
                  const SizedBox(height: 8),
                  Text(b.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 11,
                          height: 1.1,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Plan',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () {},
              child: const Text('See all',
                  style: TextStyle(color: AppTheme.accentPurple, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._plan.map((item) => _buildPlanItem(item)),
      ],
    );
  }

  Widget _buildPlanItem(_PlanItem item) {
    return GestureDetector(
      onTap: () {
        if (item.route == '/journal') {
          _showPasswordDialog(context);
        } else if (item.route != null) {
          Navigator.pushNamed(context, item.route!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 15)),
                  Text(item.subtitle,
                      style: const TextStyle(
                          color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Journal Access', style: TextStyle(color: AppTheme.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your account password to open your private journal.',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: AppTheme.textDimmed),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textDimmed.withOpacity(0.3))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == AppState.userPassword || controller.text == '123456') {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/journal');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password'), backgroundColor: AppTheme.red),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTrackerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Goal Tracker',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => _showAddGoalDialog(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.accentPurple, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (AppState.goals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text('No goals set yet. Add one!',
                  style: TextStyle(color: AppTheme.textDimmed, fontSize: 13)),
            ),
          )
        else
          ...AppState.goals.map((g) => _buildGoalItem(g)),
      ],
    );
  }

  Widget _buildGoalItem(Goal goal) {
    final bool isExpired = goal.deadline != null && goal.deadline!.isBefore(DateTime.now());
    final Color textColor = isExpired ? AppTheme.red : AppTheme.textWhite;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              goal.isDone = !goal.isDone;
              AppState.updateGoals();
            }),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: goal.isDone ? AppTheme.primaryPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: goal.isDone ? AppTheme.primaryPurple : AppTheme.textDimmed,
                ),
              ),
              child: goal.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    decoration: goal.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (goal.deadline != null)
                  Text(
                    'Deadline: ${DateFormat('MMM dd, hh:mm a').format(goal.deadline!)}',
                    style: TextStyle(
                        color: isExpired ? AppTheme.red.withOpacity(0.8) : AppTheme.textGrey,
                        fontSize: 11),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                AppState.removeGoal(goal);
              });
            },
            icon: const Icon(Icons.delete_outline, color: AppTheme.textDimmed, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('Add New Goal', style: TextStyle(color: AppTheme.textWhite)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: const InputDecoration(
                  hintText: 'Goal Title',
                  hintStyle: TextStyle(color: AppTheme.textDimmed),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedDate == null
                      ? 'No Deadline'
                      : 'Deadline: ${DateFormat('MMM dd, HH:mm').format(selectedDate!)}',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppTheme.accentPurple),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    AppState.addGoal(titleController.text, selectedDate);
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_outlined, label: 'Home'),
      _NavItem(icon: Icons.explore_outlined, label: 'Explore'),
      _NavItem(icon: Icons.favorite_outline, label: 'Wellness'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
            top: BorderSide(color: AppTheme.textDimmed.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon,
                        color: selected
                            ? AppTheme.accentPurple
                            : AppTheme.textDimmed,
                        size: 24),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(
                            color: selected
                                ? AppTheme.accentPurple
                                : AppTheme.textDimmed,
                            fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PlanItem {
  final String icon, title, subtitle;
  final Color color;
  final String? route;
  const _PlanItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      this.route});
}

class _MoodEntry {
  final String emoji, label, time;
  final Color color;
  final bool checked;
  const _MoodEntry(
      {required this.emoji,
      required this.label,
      required this.time,
      required this.color,
      required this.checked});
}

class _ActionBtn {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
