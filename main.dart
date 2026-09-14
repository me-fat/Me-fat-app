import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.load();
  runApp(const MeFatApp());
}

class MeFatApp extends StatelessWidget {
  const MeFatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ME fat',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF168BFF),
          surface: Color(0xFF111820),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111820),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF25303B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF168BFF)),
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: AppData.profile == null || !AppData.isLoggedIn ? const WelcomeScreen() : const HomeScreen(),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF168BFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class PageShell extends StatelessWidget {
  const PageShell({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: const Color(0xFF168BFF),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: const Text('ME', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),
              const Text('ME fat', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('تدرّب اليوم. كن أقوى غداً.', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              AppButton(
                text: 'إنشاء حساب',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFF36414B)),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) => PageShell(
    title: 'تسجيل الدخول',
    child: Column(children: [
      const SizedBox(height: 24),
      const Text('ME fat', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
      const SizedBox(height: 30),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline))),
      const Spacer(),
      AppButton(text: loading ? 'جاري الدخول...' : 'دخول', onPressed: () async {
        if (loading) return;
        setState(() => loading = true);
        final ok = await AppData.checkCredentials(email.text.trim(), password.text);
        if (!context.mounted) return;
        setState(() => loading = false);
        if (ok && AppData.profile != null) {
          await AppData.setLoggedIn(true);
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة')));
        }
      }),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: const Text('إنشاء حساب جديد')),
    ]),
  );
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) => PageShell(
    title: 'إنشاء حساب',
    child: Column(children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 14),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline))),
      const Spacer(),
      AppButton(text: 'التالي', onPressed: () {
        if (name.text.trim().isEmpty || !email.text.contains('@') || password.text.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل البيانات، وكلمة المرور 6 أحرف على الأقل')));
          return;
        }
        AppData.saveCredentials(email.text.trim(), password.text);
        Navigator.push(context, MaterialPageRoute(builder: (_) => BasicsScreen(name: name.text.trim(), email: email.text.trim())));
      }),
    ]),
  );
}

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({super.key, required this.name, required this.email});
  final String name;
  final String email;
  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  String gender = 'ذكر';
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  @override
  Widget build(BuildContext context) => PageShell(
    title: 'معلوماتك الأساسية',
    child: Column(children: [
      TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمر')),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: ChoiceChip(label: const Text('ذكر'), selected: gender == 'ذكر', onSelected: (_) => setState(() => gender = 'ذكر'))),
        const SizedBox(width: 10),
        Expanded(child: ChoiceChip(label: const Text('أنثى'), selected: gender == 'أنثى', onSelected: (_) => setState(() => gender = 'أنثى'))),
      ]),
      const SizedBox(height: 14),
      TextField(controller: height, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الطول (سم)')),
      const SizedBox(height: 14),
      TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الوزن (كجم)')),
      const Spacer(),
      AppButton(text: 'التالي', onPressed: () {
        final a = int.tryParse(age.text), h = double.tryParse(height.text), w = double.tryParse(weight.text);
        if (a == null || h == null || w == null || a <= 0 || h <= 0 || w <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل العمر والطول والوزن بشكل صحيح')));
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => GoalScreen(name: widget.name, email: widget.email, age: a, gender: gender, height: h, weight: w)));
      }),
    ]),
  );
}

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key, required this.name, required this.email, required this.age, required this.gender, required this.height, required this.weight});
  final String name, email, gender;
  final int age;
  final double height, weight;
  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int selected = 0;
  final goals = const [('بناء العضلات', Icons.fitness_center), ('خسارة الدهون', Icons.local_fire_department_outlined), ('زيادة القوة', Icons.sports_gymnastics), ('تحسين اللياقة والصحة', Icons.favorite_border)];
  @override
  Widget build(BuildContext context) => PageShell(
    title: 'وش هدفك؟',
    child: Column(children: [
      ...List.generate(goals.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ListTile(
        tileColor: selected == i ? const Color(0xFF0B3259) : const Color(0xFF111820),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: selected == i ? const Color(0xFF168BFF) : const Color(0xFF25303B))),
        leading: Icon(goals[i].$2), title: Text(goals[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)), onTap: () => setState(() => selected = i),
      ))),
      const Spacer(),
      AppButton(text: 'التالي', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelScreen(
        name: widget.name, email: widget.email, age: widget.age, gender: widget.gender, height: widget.height, weight: widget.weight, goal: goals[selected].$1,
      )))),
    ]),
  );
}

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key, required this.name, required this.email, required this.age, required this.gender, required this.height, required this.weight, required this.goal});
  final String name, email, gender, goal;
  final int age;
  final double height, weight;
  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int selected = 0;
  final levels = const [('مبتدئ', 'أقل من 6 أشهر من التمرين المنتظم'), ('متوسط', 'من 6 أشهر إلى سنتين'), ('متقدم', 'أكثر من سنتين من التمرين المنتظم')];
  @override
  Widget build(BuildContext context) => PageShell(
    title: 'مستواك الحالي',
    child: Column(children: [
      ...List.generate(levels.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ListTile(
        contentPadding: const EdgeInsets.all(18), tileColor: selected == i ? const Color(0xFF0B3259) : const Color(0xFF111820),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: selected == i ? const Color(0xFF168BFF) : const Color(0xFF25303B))),
        title: Text(levels[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(levels[i].$2), onTap: () => setState(() => selected = i),
      ))),
      const Spacer(),
      AppButton(text: 'ابدأ رحلتك', onPressed: () async {
        await AppData.saveProfile(UserProfile(name: widget.name, email: widget.email, age: widget.age, gender: widget.gender, height: widget.height, weight: widget.weight, goal: widget.goal, level: levels[selected].$1));
        await AppData.setLoggedIn(true);
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
      }),
    ]),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeDashboard(onChanged: () => setState(() {})),
      const MuscleScreen(embedded: true),
      const HistoryScreen(embedded: true),
      const InBodyScreen(embedded: true),
      const AccountScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'التمارين'),
          NavigationDestination(icon: Icon(Icons.history), label: 'السجل'),
          NavigationDestination(icon: Icon(Icons.monitor_weight_outlined), label: 'InBody'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
      body: SafeArea(child: pages[index]),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final profile = AppData.profile;
    final last = AppData.workouts.isEmpty ? null : AppData.workouts.first;
    final body = AppData.bodyEntries.isEmpty ? null : AppData.bodyEntries.first;
    final previousBody = AppData.bodyEntries.length > 1 ? AppData.bodyEntries[1] : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مرحباً ${profile?.name ?? ''} 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(profile == null ? 'جاهز لتمرين جديد؟' : '${profile.goal} • ${profile.level}', style: const TextStyle(color: Colors.white60)),
          ])),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF25303B))),
            alignment: Alignment.center,
            child: Text((profile?.name.isNotEmpty ?? false) ? profile!.name.substring(0, 1).toUpperCase() : 'R', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF168BFF))),
          ),
        ]),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0D2235), Color(0xFF111820)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF168BFF).withOpacity(.28)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: const Color(0xFF123A60), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.fitness_center, size: 28, color: Color(0xFF168BFF)),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('جاهز للتمرين؟', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('اختر العضلة وسجّل أرقامك', style: TextStyle(color: Colors.white60)),
              ])),
            ]),
            const SizedBox(height: 18),
            AppButton(text: 'ابدأ تمرينك', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MuscleScreen()))),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('ملخصك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.calendar_month_outlined, value: '${_workoutsThisWeek()}', label: 'تمارين هذا الأسبوع')),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(icon: Icons.trending_up, value: _totalVolumeText(), label: 'الحجم التدريبي')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _HomeMiniCard(
            icon: Icons.history,
            title: 'آخر تمرين',
            value: last == null ? 'لا يوجد بعد' : last.exerciseName,
            detail: last == null ? 'ابدأ أول تمرين لك' : '${last.totalSets} جولات • ${last.volume.toStringAsFixed(0)} كجم',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          )),
          const SizedBox(width: 12),
          Expanded(child: _HomeMiniCard(
            icon: Icons.monitor_weight_outlined,
            title: 'آخر قياس',
            value: body == null ? 'غير مضاف' : '${body.weight.toStringAsFixed(1)} كجم',
            detail: body == null ? 'أضف قياس InBody' : _bodyDeltaText(body, previousBody),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const InBodyScreen()));
              onChanged();
            },
          )),
        ]),
        const SizedBox(height: 22),
        const Text('وصول سريع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _QuickAction(icon: Icons.search, label: 'استعرض التمارين', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MuscleScreen())))),
          const SizedBox(width: 10),
          Expanded(child: _QuickAction(icon: Icons.insights_outlined, label: 'شاهد تقدمك', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())))),
        ]),
      ],
    );
  }

  int _workoutsThisWeek() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return AppData.workouts.where((w) => !w.date.isBefore(start)).length;
  }

  String _totalVolumeText() {
    final total = AppData.workouts.fold<double>(0, (sum, w) => sum + w.volume);
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)} طن';
    return '${total.toStringAsFixed(0)} كجم';
  }

  String _bodyDeltaText(BodyEntry current, BodyEntry? previous) {
    if (previous == null) return 'أول قياس محفوظ';
    final delta = current.weight - previous.weight;
    if (delta.abs() < .05) return 'بدون تغير عن السابق';
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)} كجم عن السابق';
  }
}

class _HomeMiniCard extends StatelessWidget {
  const _HomeMiniCard({required this.icon, required this.title, required this.value, required this.detail, required this.onTap});
  final IconData icon;
  final String title, value, detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF25303B))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF168BFF), size: 26),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 3),
        Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFF0D2235), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF168BFF).withOpacity(.22))),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF168BFF), size: 21),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
        const Icon(Icons.chevron_left, color: Colors.white38, size: 18),
      ]),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF111820),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF25303B)),
    ),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF168BFF), size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
    ]),
  );
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF168BFF), size: 30),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(subtitle, style: const TextStyle(color: Colors.white60), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

class MuscleScreen extends StatelessWidget {
  const MuscleScreen({super.key, this.embedded = false});
  final bool embedded;
  final muscles = const ['الصدر', 'الظهر', 'الأكتاف', 'بايسبس', 'ترايسبس', 'الأرجل', 'البطن'];

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
        itemCount: muscles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
        itemBuilder: (_, i) => InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseListScreen(muscle: muscles[i]))),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF25303B))),
            alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.accessibility_new, size: 52, color: Color(0xFF168BFF)),
              const SizedBox(height: 10),
              Text(muscles[i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
    if (embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('التمارين', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Expanded(child: grid),
        ]),
      );
    }
    return PageShell(title: 'اختر العضلة', child: grid);
  }
}

class Exercise {
  final String name;
  final String muscle;
  final String cue;
  const Exercise(this.name, this.muscle, this.cue);
}

const exerciseLibrary = <Exercise>[
  Exercise('بنش برس بالبار', 'الصدر', 'ثبّت كتفك وانزل البار بتحكم.'),
  Exercise('ضغط دمبل مائل', 'الصدر', 'حافظ على زاوية ثابتة وادفع للأعلى.'),
  Exercise('تفتيح كيبل', 'الصدر', 'اجمع اليدين أمام الصدر بدون قفل المرفق.'),
  Exercise('سحب علوي', 'الظهر', 'اسحب بالمرفقين للأسفل وحافظ على الصدر مرفوعًا.'),
  Exercise('تجديف كيبل', 'الظهر', 'اسحب باتجاه البطن واعصر لوحي الكتف.'),
  Exercise('سحب دمبل يد واحدة', 'الظهر', 'حافظ على الظهر ثابتًا واسحب بالمرفق.'),
  Exercise('ضغط كتف دمبل', 'الأكتاف', 'ادفع للأعلى بدون تقويس مبالغ للظهر.'),
  Exercise('رفرفة جانبية', 'الأكتاف', 'ارفع حتى مستوى الكتف بتحكم.'),
  Exercise('رفرفة خلفية', 'الأكتاف', 'افتح الذراعين واعصر الكتف الخلفي.'),
  Exercise('بايسبس دمبل', 'بايسبس', 'ثبّت المرفق وارفع بدون تأرجح.'),
  Exercise('هامر كيرل', 'بايسبس', 'حافظ على قبضة محايدة طوال الحركة.'),
  Exercise('ترايسبس كيبل', 'ترايسبس', 'ثبّت المرفقين بجانب الجسم ومد الذراع.'),
  Exercise('تمديد ترايسبس فوق الرأس', 'ترايسبس', 'حافظ على المرفقين للأمام ومد الذراع بالكامل.'),
  Exercise('سكوات', 'الأرجل', 'انزل بتحكم وحافظ على الركبتين باتجاه القدمين.'),
  Exercise('ليج برس', 'الأرجل', 'لا تقفل الركبتين وابقِ أسفل الظهر ثابتًا.'),
  Exercise('ليج كيرل', 'الأرجل', 'اثنِ الركبة بتحكم واعصر العضلة الخلفية.'),
  Exercise('كرنش', 'البطن', 'قرّب القفص الصدري للحوض بدون شد الرقبة.'),
  Exercise('بلانك', 'البطن', 'حافظ على الجسم بخط مستقيم وشد البطن.'),
];

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key, required this.muscle});
  final String muscle;

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final items = exerciseLibrary
        .where((e) => e.muscle == widget.muscle && e.name.contains(query.trim()))
        .toList();
    return PageShell(
      title: 'تمارين ${widget.muscle}',
      child: Column(children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'ابحث عن تمرين',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('ما لقينا تمرين بهذا الاسم', style: TextStyle(color: Colors.white60)))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final e = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      tileColor: const Color(0xFF111820),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF25303B))),
                      leading: const CircleAvatar(backgroundColor: Color(0xFF0B3259), child: Icon(Icons.fitness_center, color: Color(0xFF168BFF))),
                      title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(e.cue, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: e))),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: exercise.name,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 220,
          decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(20)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.play_circle_fill, size: 76, color: Color(0xFF168BFF)),
            SizedBox(height: 8),
            Text('فيديو شرح التمرين', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Text(exercise.muscle, style: const TextStyle(color: Color(0xFF168BFF), fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(exercise.cue, style: const TextStyle(fontSize: 17, height: 1.6)),
        const Spacer(),
        AppButton(text: 'ابدأ تسجيل التمرين', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutLogScreen(exercise: exercise)))),
      ]),
    );
  }
}

class WorkoutSet {
  WorkoutSet({double weight = 0, int reps = 0, this.done = false})
      : weightController = TextEditingController(text: weight > 0 ? _fmtWeight(weight) : ''),
        repsController = TextEditingController(text: reps > 0 ? '$reps' : '');

  final TextEditingController weightController;
  final TextEditingController repsController;
  bool done;

  double get weight => double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0;
  int get reps => int.tryParse(repsController.text) ?? 0;

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }

  static String _fmtWeight(double value) => value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key, required this.exercise});
  final Exercise exercise;
  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final sets = <WorkoutSet>[];

  @override
  void initState() {
    super.initState();
    _addBlankSets();
  }

  void _addBlankSets() {
    sets.addAll([WorkoutSet(), WorkoutSet(), WorkoutSet()]);
  }

  LoggedWorkout? get _previousWorkout {
    final previous = AppData.workouts.where((w) => w.exerciseName == widget.exercise.name).toList();
    return previous.isEmpty ? null : previous.first;
  }

  @override
  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previous = _previousWorkout;
    return PageShell(
      title: widget.exercise.name,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0B3259), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.history, color: Color(0xFF168BFF)),
            const SizedBox(width: 10),
            Expanded(child: Text(_previousText(previous))),
            if (previous != null)
              TextButton(
                onPressed: () => _loadPrevious(previous),
                child: const Text('استخدم السابق'),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _MiniStat(value: '${sets.where((s) => s.done).length}', label: 'مكتملة')),
          const SizedBox(width: 10),
          Expanded(child: _MiniStat(value: _currentVolume().toStringAsFixed(0), label: 'الحجم الحالي')),
        ]),
        const SizedBox(height: 18),
        const Row(children: [
          SizedBox(width: 42, child: Text('#', textAlign: TextAlign.center)),
          Expanded(child: Text('الوزن كجم', textAlign: TextAlign.center)),
          SizedBox(width: 8),
          Expanded(child: Text('التكرارات', textAlign: TextAlign.center)),
          SizedBox(width: 92),
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: sets.length,
            itemBuilder: (_, i) => _setRow(i),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _addSet,
          icon: const Icon(Icons.add),
          label: const Text('إضافة جولة'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
        const SizedBox(height: 10),
        AppButton(text: 'حفظ وإنهاء', onPressed: _finish),
      ]),
    );
  }

  Widget _setRow(int i) {
    final set = sets[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(
          width: 42,
          child: Text('${i + 1}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: TextField(
            controller: set.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '0'),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: set.repsController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '0'),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          width: 48,
          child: IconButton.filledTonal(
            tooltip: 'تمت الجولة',
            onPressed: () => setState(() => set.done = !set.done),
            icon: Icon(set.done ? Icons.check_circle : Icons.circle_outlined),
          ),
        ),
        SizedBox(
          width: 44,
          child: IconButton(
            tooltip: 'حذف الجولة',
            onPressed: sets.length == 1 ? null : () => _removeSet(i),
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
      ]),
    );
  }

  String _previousText(LoggedWorkout? previous) {
    if (previous == null) return 'لا يوجد سجل سابق لهذا التمرين';
    if (previous.sets.isEmpty) return 'آخر تمرين: ${previous.totalSets} جولات';
    final best = previous.sets.reduce((a, b) => a.weight > b.weight ? a : b);
    final weight = best.weight % 1 == 0 ? best.weight.toStringAsFixed(0) : best.weight.toStringAsFixed(1);
    return 'السابق: $weight كجم × ${best.reps}';
  }

  double _currentVolume() => sets.fold<double>(0, (sum, s) => sum + (s.weight * s.reps));

  void _loadPrevious(LoggedWorkout previous) {
    for (final set in sets) {
      set.dispose();
    }
    sets
      ..clear()
      ..addAll(previous.sets.map((s) => WorkoutSet(weight: s.weight, reps: s.reps)));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعبئة أرقام التمرين السابق')));
  }

  void _addSet() {
    final last = sets.isNotEmpty ? sets.last : null;
    setState(() {
      sets.add(WorkoutSet(weight: last?.weight ?? 0, reps: last?.reps ?? 0));
    });
  }

  void _removeSet(int index) {
    setState(() {
      final removed = sets.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _finish() async {
    final completed = sets.where((s) => s.done || (s.weight > 0 && s.reps > 0)).toList();
    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجّل جولة واحدة على الأقل')));
      return;
    }
    final volume = completed.fold<double>(0, (sum, s) => sum + (s.weight * s.reps));
    await AppData.addWorkout(LoggedWorkout(
      exerciseName: widget.exercise.name,
      muscle: widget.exercise.muscle,
      date: DateTime.now(),
      sets: completed.map((s) => LoggedSet(weight: s.weight, reps: s.reps)).toList(),
    ));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkoutSummaryScreen(exercise: widget.exercise, sets: completed.length, volume: volume)));
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111820),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF25303B)),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
      );
}

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key, required this.exercise, required this.sets, required this.volume});
  final Exercise exercise;
  final int sets;
  final double volume;

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'تم الحفظ ✓',
      child: Column(children: [
        const Spacer(),
        const Icon(Icons.emoji_events_outlined, size: 92, color: Color(0xFF168BFF)),
        const SizedBox(height: 16),
        const Text('أحسنت!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(exercise.name, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(child: _SummaryCard(value: '$sets', label: 'الجولات')),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(value: volume.toStringAsFixed(0), label: 'الحجم كجم')),
        ]),
        const Spacer(),
        AppButton(text: 'العودة للرئيسية', onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false)),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 22),
    decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(18)),
    child: Column(children: [Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white60))]),
  );
}


class LoggedSet {
  const LoggedSet({required this.weight, required this.reps});
  final double weight;
  final int reps;

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};
  factory LoggedSet.fromJson(Map<String, dynamic> json) => LoggedSet(
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
    reps: (json['reps'] as num?)?.toInt() ?? 0,
  );
}

class LoggedWorkout {
  const LoggedWorkout({required this.exerciseName, required this.muscle, required this.date, required this.sets});
  final String exerciseName;
  final String muscle;
  final DateTime date;
  final List<LoggedSet> sets;

  int get totalSets => sets.length;
  double get volume => sets.fold(0, (sum, s) => sum + (s.weight * s.reps));

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'muscle': muscle,
    'date': date.toIso8601String(),
    'sets': sets.map((e) => e.toJson()).toList(),
  };

  factory LoggedWorkout.fromJson(Map<String, dynamic> json) => LoggedWorkout(
    exerciseName: json['exerciseName'] as String? ?? '',
    muscle: json['muscle'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    sets: ((json['sets'] as List?) ?? const [])
        .map((e) => LoggedSet.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

class BodyEntry {
  const BodyEntry({required this.date, required this.weight, required this.muscleMass, required this.bodyFat});
  final DateTime date;
  final double weight;
  final double muscleMass;
  final double bodyFat;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
    'muscleMass': muscleMass,
    'bodyFat': bodyFat,
  };

  factory BodyEntry.fromJson(Map<String, dynamic> json) => BodyEntry(
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
    muscleMass: (json['muscleMass'] as num?)?.toDouble() ?? 0,
    bodyFat: (json['bodyFat'] as num?)?.toDouble() ?? 0,
  );
}

class UserProfile {
  const UserProfile({required this.name, required this.email, required this.age, required this.gender, required this.height, required this.weight, required this.goal, required this.level});
  final String name, email, gender, goal, level;
  final int age;
  final double height, weight;
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'age': age, 'gender': gender, 'height': height, 'weight': weight, 'goal': goal, 'level': level};
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(name: j['name'] ?? '', email: j['email'] ?? '', age: (j['age'] as num?)?.toInt() ?? 0, gender: j['gender'] ?? '', height: (j['height'] as num?)?.toDouble() ?? 0, weight: (j['weight'] as num?)?.toDouble() ?? 0, goal: j['goal'] ?? '', level: j['level'] ?? '');
}

class AppData {
  static UserProfile? profile;
  static bool isLoggedIn = false;
  static List<LoggedWorkout> workouts = [];
  static List<BodyEntry> bodyEntries = [];
  static const _profileKey = 'profile_v1';
  static const _workoutsKey = 'workouts_v1';
  static const _bodyKey = 'body_entries_v1';
  static const _emailKey = 'login_email_v1';
  static const _passwordKey = 'login_password_v1';
  static const _sessionKey = 'session_logged_in_v1';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileRaw = prefs.getString(_profileKey);
    isLoggedIn = prefs.getBool(_sessionKey) ?? false;
    final workoutsRaw = prefs.getString(_workoutsKey);
    if (profileRaw != null) { try { profile = UserProfile.fromJson(Map<String, dynamic>.from(jsonDecode(profileRaw) as Map)); } catch (_) {} }
    final bodyRaw = prefs.getString(_bodyKey);
    if (workoutsRaw != null) {
      try {
        final list = jsonDecode(workoutsRaw) as List;
        workouts = list.map((e) => LoggedWorkout.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } catch (_) {}
    }
    if (bodyRaw != null) {
      try {
        final list = jsonDecode(bodyRaw) as List;
        bodyEntries = list.map((e) => BodyEntry.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } catch (_) {}
    }
  }



  static Future<void> setLoggedIn(bool value) async {
    isLoggedIn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, value);
  }

  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.toLowerCase());
    await prefs.setString(_passwordKey, password);
  }

  static Future<bool> checkCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) == email.toLowerCase() && prefs.getString(_passwordKey) == password;
  }

  static Future<void> saveProfile(UserProfile value) async {
    profile = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(value.toJson()));
  }

  static Future<void> addWorkout(LoggedWorkout workout) async {
    workouts.insert(0, workout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutsKey, jsonEncode(workouts.map((e) => e.toJson()).toList()));
  }

  static Future<void> addBodyEntry(BodyEntry entry) async {
    bodyEntries.insert(0, entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bodyKey, jsonEncode(bodyEntries.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearAll() async {
    profile = null;
    workouts = [];
    bodyEntries = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_workoutsKey);
    await prefs.remove(_bodyKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_sessionKey);
    isLoggedIn = false;
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = 'الكل';

  List<LoggedWorkout> get _filtered {
    if (filter == 'الكل') return AppData.workouts;
    return AppData.workouts.where((w) => w.muscle == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = _filtered;
    final muscles = <String>{'الكل', ...AppData.workouts.map((e) => e.muscle)}.toList();
    final totalVolume = AppData.workouts.fold<double>(0, (sum, w) => sum + w.volume);
    final totalSets = AppData.workouts.fold<int>(0, (sum, w) => sum + w.totalSets);
    final thisWeek = AppData.workouts.where((w) => DateTime.now().difference(w.date).inDays < 7).length;
    final best = _bestSet();

    final content = AppData.workouts.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.history, size: 70, color: Color(0xFF168BFF)),
            SizedBox(height: 12),
            Text('ما عندك تمارين مسجلة بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]))
        : ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(children: [
                Expanded(child: _ProgressStat(value: '$thisWeek', label: 'هذا الأسبوع', icon: Icons.calendar_month_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _ProgressStat(value: '$totalSets', label: 'إجمالي الجولات', icon: Icons.repeat)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _ProgressStat(value: totalVolume.toStringAsFixed(0), label: 'الحجم كجم', icon: Icons.insights_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _ProgressStat(value: best == null ? '—' : '${best.$1.toStringAsFixed(best.$1 % 1 == 0 ? 0 : 1)}', label: best == null ? 'أفضل وزن' : 'أفضل وزن كجم', icon: Icons.emoji_events_outlined)),
              ]),
              const SizedBox(height: 18),
              const Text('نشاط آخر 7 أيام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _SevenDayChart(workouts: AppData.workouts),
              if (best != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2235),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF168BFF).withOpacity(.35)),
                  ),
                  child: Row(children: [
                    const CircleAvatar(backgroundColor: Color(0xFF123A60), child: Icon(Icons.workspace_premium_outlined, color: Color(0xFF168BFF))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('أفضل رقم مسجل', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text('${best.$2} • ${best.$1.toStringAsFixed(best.$1 % 1 == 0 ? 0 : 1)} كجم × ${best.$3}', style: const TextStyle(color: Colors.white70)),
                    ])),
                  ]),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: muscles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final item = muscles[i];
                    return ChoiceChip(
                      label: Text(item),
                      selected: filter == item,
                      onSelected: (_) => setState(() => filter = item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              if (workouts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 34),
                  child: Center(child: Text('لا توجد تمارين بهذا التصنيف', style: TextStyle(color: Colors.white60))),
                )
              else
                ...workouts.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WorkoutHistoryCard(workout: w),
                )),
              const SizedBox(height: 18),
            ],
          );

    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('التقدم والسجل', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Expanded(child: content),
        ]),
      );
    }
    return PageShell(title: 'التقدم والسجل', child: content);
  }

  (double, String, int)? _bestSet() {
    double bestWeight = -1;
    String exercise = '';
    int reps = 0;
    for (final w in AppData.workouts) {
      for (final s in w.sets) {
        if (s.weight > bestWeight) {
          bestWeight = s.weight;
          exercise = w.exerciseName;
          reps = s.reps;
        }
      }
    }
    return bestWeight < 0 ? null : (bestWeight, exercise, reps);
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF111820),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF25303B)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF168BFF), size: 20),
      const SizedBox(height: 8),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  );
}

class _SevenDayChart extends StatelessWidget {
  const _SevenDayChart({required this.workouts});
  final List<LoggedWorkout> workouts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final volume = workouts.where((w) => _sameDay(w.date, d)).fold<double>(0, (sum, w) => sum + w.volume);
      return (d, volume);
    });
    final maxV = days.fold<double>(0, (m, e) => e.$2 > m ? e.$2 : m);
    const names = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];

    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF25303B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((entry) {
          final ratio = maxV == 0 ? 0.0 : entry.$2 / maxV;
          return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(entry.$2 == 0 ? '' : entry.$2.toStringAsFixed(0), style: const TextStyle(fontSize: 10, color: Colors.white54)),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 20,
                height: 16 + (92 * ratio),
                decoration: BoxDecoration(
                  color: entry.$2 == 0 ? const Color(0xFF26313B) : const Color(0xFF168BFF),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 7),
              Text(names[entry.$1.weekday - 1], style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WorkoutHistoryCard extends StatelessWidget {
  const _WorkoutHistoryCard({required this.workout});
  final LoggedWorkout workout;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF111820),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF25303B)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(backgroundColor: Color(0xFF0B3259), child: Icon(Icons.fitness_center, color: Color(0xFF168BFF))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(workout.exerciseName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text('${workout.muscle} • ${_dateText(workout.date)}', style: const TextStyle(color: Colors.white60)),
        ])),
        Text('${workout.totalSets} جولات', style: const TextStyle(color: Color(0xFF168BFF), fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: workout.sets.asMap().entries.map((entry) {
        final set = entry.value;
        return Chip(label: Text('${entry.key + 1}: ${set.weight.toStringAsFixed(set.weight % 1 == 0 ? 0 : 1)} كجم × ${set.reps}'));
      }).toList()),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.insights, size: 16, color: Color(0xFF168BFF)),
        const SizedBox(width: 6),
        Text('الحجم: ${workout.volume.toStringAsFixed(0)} كجم', style: const TextStyle(color: Colors.white70)),
      ]),
    ]),
  );
}

class InBodyScreen extends StatefulWidget {
  const InBodyScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<InBodyScreen> createState() => _InBodyScreenState();
}

class _InBodyScreenState extends State<InBodyScreen> {
  String metric = 'الوزن';

  Future<void> _addEntry() async {
    final weight = TextEditingController();
    final muscle = TextEditingController();
    final fat = TextEditingController();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111820),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('إضافة قياس InBody', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الوزن (كجم)')),
          const SizedBox(height: 12),
          TextField(controller: muscle, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'كتلة العضلات (كجم)')),
          const SizedBox(height: 12),
          TextField(controller: fat, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'نسبة الدهون %')),
          const SizedBox(height: 18),
          AppButton(text: 'حفظ القياس', onPressed: () => Navigator.pop(ctx, true)),
        ]),
      ),
    );
    if (result != true) return;
    final w = double.tryParse(weight.text.replaceAll(',', '.'));
    if (w == null || w <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الوزن بشكل صحيح')));
      return;
    }
    await AppData.addBodyEntry(BodyEntry(
      date: DateTime.now(),
      weight: w,
      muscleMass: double.tryParse(muscle.text.replaceAll(',', '.')) ?? 0,
      bodyFat: double.tryParse(fat.text.replaceAll(',', '.')) ?? 0,
    ));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = AppData.bodyEntries;
    final content = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppButton(text: 'إضافة قياس جديد', onPressed: _addEntry),
      const SizedBox(height: 18),
      if (list.isEmpty)
        const Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.monitor_weight_outlined, size: 66, color: Color(0xFF168BFF)),
          SizedBox(height: 12),
          Text('أضف أول قياس لك', style: TextStyle(color: Colors.white60, fontSize: 17)),
        ])))
      else ...[
        Row(children: [
          Expanded(child: _MetricCard(label: 'الوزن', value: '${list.first.weight.toStringAsFixed(1)} كجم')),
          const SizedBox(width: 10),
          Expanded(child: _MetricCard(label: 'العضلات', value: list.first.muscleMass > 0 ? '${list.first.muscleMass.toStringAsFixed(1)} كجم' : '—')),
          const SizedBox(width: 10),
          Expanded(child: _MetricCard(label: 'الدهون', value: list.first.bodyFat > 0 ? '${list.first.bodyFat.toStringAsFixed(1)}%' : '—')),
        ]),
        if (list.length > 1) ...[
          const SizedBox(height: 12),
          _BodyChangeCard(current: list[0], previous: list[1]),
        ],
        const SizedBox(height: 18),
        Row(children: [
          const Expanded(child: Text('تطور القياسات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'الوزن', label: Text('وزن')),
              ButtonSegment(value: 'العضلات', label: Text('عضل')),
              ButtonSegment(value: 'الدهون', label: Text('دهون')),
            ],
            selected: {metric},
            onSelectionChanged: (value) => setState(() => metric = value.first),
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ]),
        const SizedBox(height: 10),
        _BodyTrendChart(entries: list, metric: metric),
        const SizedBox(height: 18),
        const Text('القياسات السابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Expanded(child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final b = list[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111820),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF25303B)),
              ),
              child: Row(children: [
                const CircleAvatar(backgroundColor: Color(0xFF0B3259), child: Icon(Icons.monitor_weight_outlined, color: Color(0xFF168BFF))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${b.weight.toStringAsFixed(1)} كجم', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(_dateText(b.date), style: const TextStyle(color: Colors.white54)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (b.muscleMass > 0) Text('${b.muscleMass.toStringAsFixed(1)} كجم عضل', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  if (b.bodyFat > 0) Text('${b.bodyFat.toStringAsFixed(1)}% دهون', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ]),
              ]),
            );
          },
        )),
      ],
    ]);

    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('InBody', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Expanded(child: content),
        ]),
      );
    }
    return PageShell(title: 'InBody', child: content);
  }
}

class _BodyTrendChart extends StatelessWidget {
  const _BodyTrendChart({required this.entries, required this.metric});
  final List<BodyEntry> entries;
  final String metric;

  double _value(BodyEntry e) {
    if (metric == 'العضلات') return e.muscleMass;
    if (metric == 'الدهون') return e.bodyFat;
    return e.weight;
  }

  @override
  Widget build(BuildContext context) {
    final usable = entries.where((e) => _value(e) > 0).take(8).toList().reversed.toList();
    if (usable.length < 2) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF111820),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF25303B)),
        ),
        child: const Text('أضف قياسين أو أكثر لعرض الرسم', style: TextStyle(color: Colors.white54)),
      );
    }
    final values = usable.map(_value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final first = values.first;
    final last = values.last;
    final change = last - first;
    final suffix = metric == 'الدهون' ? '%' : ' كجم';
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF25303B)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text('${last.toStringAsFixed(1)}$suffix', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Text('${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}$suffix', style: const TextStyle(color: Color(0xFF168BFF), fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            painter: _TrendPainter(values: values, minValue: minV, maxValue: maxV),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_shortDate(usable.first.date), style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(_shortDate(usable.last.date), style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ]),
    );
  }

  static String _shortDate(DateTime d) => '${d.day}/${d.month}';
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.values, required this.minValue, required this.maxValue});
  final List<double> values;
  final double minValue;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFF25303B)..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..color = const Color(0xFF168BFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = const Color(0xFF168BFF);
    final path = Path();
    final range = (maxValue - minValue).abs() < 0.001 ? 1.0 : maxValue - minValue;
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - 8 - normalized * (size.height - 16);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dot);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.minValue != minValue || oldDelegate.maxValue != maxValue;
}

class _BodyChangeCard extends StatelessWidget {
  const _BodyChangeCard({required this.current, required this.previous});
  final BodyEntry current;
  final BodyEntry previous;

  String _delta(double a, double b, String suffix) {
    final d = a - b;
    if (d == 0) return '0$suffix';
    return '${d > 0 ? '+' : ''}${d.toStringAsFixed(1)}$suffix';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF0B3259),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF168BFF).withOpacity(.35)),
    ),
    child: Row(children: [
      const Icon(Icons.compare_arrows, color: Color(0xFF168BFF)),
      const SizedBox(width: 10),
      Expanded(child: Text('من آخر قياس: الوزن ${_delta(current.weight, previous.weight, ' كجم')}${current.muscleMass > 0 && previous.muscleMass > 0 ? ' • العضلات ${_delta(current.muscleMass, previous.muscleMass, ' كجم')}' : ''}${current.bodyFat > 0 && previous.bodyFat > 0 ? ' • الدهون ${_delta(current.bodyFat, previous.bodyFat, '%')}' : ''}')),
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _editProfile() async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        content: const Text('بياناتك وتمارينك ستبقى محفوظة على الجهاز.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خروج')),
        ],
      ),
    );
    if (ok != true) return;
    await AppData.setLoggedIn(false);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  Future<void> _clearData(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف بيانات التجربة؟'),
        content: const Text('سيتم حذف الحساب المحلي والسجل وقياسات InBody من هذا الجهاز.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    await AppData.clearAll();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(children: [
        const Expanded(child: Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
        IconButton(onPressed: _editProfile, tooltip: 'تعديل', icon: const Icon(Icons.edit_outlined)),
      ]),
      const SizedBox(height: 20),
      const CircleAvatar(radius: 42, backgroundColor: Color(0xFF0B3259), child: Icon(Icons.person, size: 48, color: Color(0xFF168BFF))),
      const SizedBox(height: 16),
      Text(AppData.profile?.name ?? 'مستخدم ME fat', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(AppData.profile?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: _editProfile, icon: const Icon(Icons.edit_outlined), label: const Text('تعديل الملف الشخصي'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50))),
      const SizedBox(height: 16),
      ListTile(tileColor: const Color(0xFF111820), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.flag_outlined), title: const Text('الهدف'), subtitle: Text(AppData.profile?.goal ?? '—')),
      const SizedBox(height: 10),
      ListTile(tileColor: const Color(0xFF111820), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.fitness_center), title: const Text('المستوى'), subtitle: Text(AppData.profile?.level ?? '—')),
      const SizedBox(height: 10),
      ListTile(tileColor: const Color(0xFF111820), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.straighten), title: const Text('الطول والوزن'), subtitle: Text('${AppData.profile?.height.toStringAsFixed(0) ?? '—'} سم • ${AppData.profile?.weight.toStringAsFixed(1) ?? '—'} كجم')),
      const SizedBox(height: 10),
      ListTile(tileColor: const Color(0xFF111820), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.cake_outlined), title: const Text('العمر'), subtitle: Text('${AppData.profile?.age ?? '—'} سنة')),
      const SizedBox(height: 22),
      OutlinedButton.icon(onPressed: () => _logout(context), icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50))),
      const SizedBox(height: 10),
      TextButton.icon(onPressed: () => _clearData(context), icon: const Icon(Icons.delete_outline), label: const Text('حذف بيانات التجربة')),
      const SizedBox(height: 20),
      const Text('ME fat • نسخة تجريبية', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
    ],
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController age;
  late final TextEditingController height;
  late final TextEditingController weight;
  late String gender;
  late String goal;
  late String level;

  static const goals = ['خسارة الدهون', 'بناء العضلات', 'زيادة القوة', 'تحسين اللياقة والصحة'];
  static const levels = ['مبتدئ', 'متوسط', 'متقدم'];
  static const genders = ['ذكر', 'أنثى'];

  @override
  void initState() {
    super.initState();
    final p = AppData.profile!;
    name = TextEditingController(text: p.name);
    age = TextEditingController(text: p.age.toString());
    height = TextEditingController(text: p.height.toStringAsFixed(0));
    weight = TextEditingController(text: p.weight.toStringAsFixed(1));
    gender = genders.contains(p.gender) ? p.gender : genders.first;
    goal = goals.contains(p.goal) ? p.goal : goals.first;
    level = levels.contains(p.level) ? p.level : levels.first;
  }

  @override
  void dispose() {
    name.dispose(); age.dispose(); height.dispose(); weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final old = AppData.profile!;
    final parsedAge = int.tryParse(age.text.trim());
    final parsedHeight = double.tryParse(height.text.trim());
    final parsedWeight = double.tryParse(weight.text.trim());
    if (name.text.trim().isEmpty || parsedAge == null || parsedAge < 10 || parsedAge > 100 || parsedHeight == null || parsedHeight < 100 || parsedHeight > 250 || parsedWeight == null || parsedWeight < 30 || parsedWeight > 350) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تأكد من الاسم والعمر والطول والوزن')));
      return;
    }
    await AppData.saveProfile(UserProfile(name: name.text.trim(), email: old.email, age: parsedAge, gender: gender, height: parsedHeight, weight: parsedWeight, goal: goal, level: level));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => PageShell(
    title: 'تعديل الملف الشخصي',
    child: ListView(children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 12),
      TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمر', prefixIcon: Icon(Icons.cake_outlined))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الطول (سم)'))),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الوزن (كجم)'))),
      ]),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: gender, decoration: const InputDecoration(labelText: 'الجنس'), items: genders.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => gender = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: goal, decoration: const InputDecoration(labelText: 'الهدف'), items: goals.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => goal = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: level, decoration: const InputDecoration(labelText: 'المستوى'), items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => level = v!)),
      const SizedBox(height: 24),
      AppButton(text: 'حفظ التعديلات', onPressed: _save),
    ]),
  );
}

String _dateText(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
