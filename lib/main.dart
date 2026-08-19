import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Guarantee low-level Flutter engine bindings are initialized prior to async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge monochrome status and navigation configuration.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NodistApp());
}

// ============================================================================
// DESIGN SYSTEM TOKENS & TYPOGRAPHY
// ============================================================================

/// Design tokens capturing a high-end luxury dark aesthetic.
class StudioPalette {
  StudioPalette._();

  static const Color background = Color(0xFF0A0A0C);
  static const Color surfaceGlass = Color(0xFF141418);
  static const Color cardFill = Color(0xFF18181E);
  static const Color primaryText = Color(0xFFF5F5F7);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color accentDot = Color(0xFFFFFFFF);
  static const Color completedDim = Color(0xFF48484A);

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.8,
    color: primaryText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.8,
    color: secondaryText,
  );
}

/// Root Application Widget with luxury dark styling.
class NodistApp extends StatelessWidget {
  const NodistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodist // Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: StudioPalette.background,
        primaryColor: StudioPalette.primaryText,
        colorScheme: const ColorScheme.dark(
          primary: StudioPalette.primaryText,
          surface: StudioPalette.surfaceGlass,
          onSurface: StudioPalette.primaryText,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// DATA MODEL & LOCAL STORAGE REPOSITORY
// ============================================================================

enum TaskCategory { focus, personal, work }

/// Immutable Task entity with mutation helpers and serialization.
class TaskItem {
  final String id;
  final String title;
  final TaskCategory category;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    this.category = TaskCategory.focus,
    this.isCompleted = false,
  });

  TaskItem copyWith({
    String? title,
    TaskCategory? category,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category.name,
        'isCompleted': isCompleted,
      };

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
        id: map['id'] as String,
        title: map['title'] as String,
        category: TaskCategory.values.firstWhere(
          (c) => c.name == map['category'],
          orElse: () => TaskCategory.focus,
        ),
        isCompleted: map['isCompleted'] as bool? ?? false,
      );
}

/// Local persistence manager abstraction over SharedPreferences.
class TaskRepository {
  static const String _storageKey = 'nodist_studio_payload';

  Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getStringList(_storageKey);
    if (rawData == null) return [];

    return rawData.map((item) {
      return TaskItem.fromMap(jsonDecode(item) as Map<String, dynamic>);
    }).toList();
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}

// ============================================================================
// SCREEN 1: LUXURY STUDIO SPLASH SCREEN
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _routeToWorkspace();
  }

  void _routeToWorkspace() {
    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioPalette.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Minimalist Studio Monogram
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: StudioPalette.surfaceGlass,
                  shape: BoxShape.circle,
                  border: Border.all(color: StudioPalette.glassBorder, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'N',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w200,
                    color: StudioPalette.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'NODIST',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 10,
                  color: StudioPalette.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TIME & CLARITY',
                style: StudioPalette.caption.copyWith(letterSpacing: 4),
              ),
              const Spacer(flex: 2),
              // Clean SpinKit Dot Loading Indicator
              const SpinKitThreeBounce(
                color: StudioPalette.primaryText,
                size: 16.0,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 2: WORKSPACE (HOMESCREEN)
// ============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _repository = TaskRepository();
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersistedTasks();
  }

  Future<void> _fetchPersistedTasks() async {
    final tasks = await _repository.loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _syncToDisk() async {
    await _repository.saveTasks(_tasks);
  }

  void _createTask(String title, TaskCategory category) {
    if (title.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final newTask = TaskItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      category: category,
    );
    setState(() => _tasks.insert(0, newTask));
    _syncToDisk();
  }

  void _toggleTask(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    });
    _syncToDisk();
  }

  void _deleteTask(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _tasks.removeAt(index));
    _syncToDisk();
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudioPalette.surfaceGlass,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _CreateTaskModal(
        onCreated: (title, category) {
          _createTask(title, category);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((t) => t.isCompleted).length;
    final total = _tasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: StudioPalette.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: SpinKitFadingCube(
                  color: StudioPalette.primaryText,
                  size: 22.0,
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar / Studio Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NODIST', style: StudioPalette.display),
                              SizedBox(height: 4),
                              Text('DAILY MANIFEST', style: StudioPalette.caption),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: StudioPalette.surfaceGlass,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: StudioPalette.glassBorder),
                            ),
                            child: Text(
                              '$completed / $total DONE',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: StudioPalette.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Progress Capsule Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: StudioPalette.surfaceGlass,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: StudioPalette.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'COMPLETION RATE',
                                  style: StudioPalette.caption.copyWith(fontSize: 10),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: StudioPalette.primaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: StudioPalette.cardFill,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  StudioPalette.primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Task Feed
                  _tasks.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lens_outlined,
                                  size: 32,
                                  color: StudioPalette.secondaryText.withOpacity(0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'CLEAR MIND. ADD A TASK.',
                                  style: StudioPalette.caption.copyWith(
                                    color: StudioPalette.secondaryText.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 90),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final task = _tasks[index];
                                return _StudioTaskCard(
                                  key: ValueKey(task.id),
                                  task: task,
                                  onToggle: () => _toggleTask(index),
                                  onDelete: () => _deleteTask(index),
                                );
                              },
                              childCount: _tasks.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: StudioPalette.primaryText,
        foregroundColor: StudioPalette.background,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }
}

// ============================================================================
// COMPONENT: STUDIO TASK CARD
// ============================================================================

class _StudioTaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _StudioTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: task.isCompleted ? StudioPalette.background : StudioPalette.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.isCompleted ? Colors.transparent : StudioPalette.glassBorder,
          ),
        ),
        child: Row(
          children: [
            // Custom Soft Checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? StudioPalette.primaryText : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? StudioPalette.primaryText
                        : StudioPalette.secondaryText.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 14, color: StudioPalette.background)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Meta Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: task.isCompleted
                          ? StudioPalette.completedDim
                          : StudioPalette.primaryText,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: StudioPalette.completedDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.category.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted
                          ? StudioPalette.completedDim
                          : StudioPalette.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: StudioPalette.secondaryText.withOpacity(0.4),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPONENT: MODAL BOTTOM SHEET FOR TASK CREATION
// ============================================================================

class _CreateTaskModal extends StatefulWidget {
  final void Function(String title, TaskCategory category) onCreated;

  const _CreateTaskModal({required this.onCreated});

  @override
  State<_CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<_CreateTaskModal> {
  final TextEditingController _controller = TextEditingController();
  TaskCategory _category = TaskCategory.focus;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NEW INTENTION', style: StudioPalette.caption),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(
              fontSize: 16,
              color: StudioPalette.primaryText,
              fontWeight: FontWeight.w300,
            ),
            cursorColor: StudioPalette.primaryText,
            decoration: InputDecoration(
              hintText: 'What is your focus?',
              hintStyle: TextStyle(
                color: StudioPalette.secondaryText.withOpacity(0.5),
              ),
              border: InputBorder.none,
            ),
            onSubmitted: (_) => widget.onCreated(_controller.text, _category),
          ),
          const SizedBox(height: 20),
          // Category Selector Chips
          Row(
            children: TaskCategory.values.map((cat) {
              final isSelected = _category == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    cat.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isSelected ? StudioPalette.background : StudioPalette.primaryText,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: StudioPalette.primaryText,
                  backgroundColor: StudioPalette.cardFill,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? StudioPalette.primaryText : StudioPalette.glassBorder,
                    ),
                  ),
                  onSelected: (_) => setState(() => _category = cat),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StudioPalette.primaryText,
                foregroundColor: StudioPalette.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => widget.onCreated(_controller.text, _category),
              child: const Text(
                'CREATE TASK',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}