import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter.dart';
import '../widgets/note_card.dart';
import 'add_note_screen.dart';
import 'detail_note_screen.dart';
import 'login_screen.dart';

/// Halaman utama dengan daftar catatan, pencarian, filter, arsip, dan profil.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Note> _notes;
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  NoteCategory? _selectedCategory;
  int _tabIndex = 0;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _notes = _createDummyNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _activeNotes =>
      _notes.where((note) => !note.isArchived).toList();

  List<Note> get _archivedNotes =>
      _notes.where((note) => note.isArchived).toList();

  List<Note> get _visibleNotes {
    final List<Note> source = _tabIndex == 1 ? _archivedNotes : _activeNotes;
    final String keyword = _query.trim().toLowerCase();

    final List<Note> filtered = source.where((note) {
      final bool matchesCategory =
          _selectedCategory == null || note.category == _selectedCategory;
      final bool matchesKeyword =
          keyword.isEmpty ||
          note.title.toLowerCase().contains(keyword) ||
          note.content.toLowerCase().contains(keyword);

      return matchesCategory && matchesKeyword;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  bool get _hasActiveFilter =>
      _query.trim().isNotEmpty || _selectedCategory != null;

  Future<void> _openAddNote() async {
    final Note? createdNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute<Note>(builder: (_) => const AddNoteScreen()),
    );

    if (createdNote == null || !mounted) return;

    setState(() {
      _notes.insert(0, createdNote);
      _tabIndex = 0;
      _selectedCategory = null;
      _query = '';
      _searchController.clear();
    });

    _showSnack('Catatan "${createdNote.title}" berhasil disimpan.');
  }

  Future<void> _openDetail(Note note) async {
    final NoteResult? result = await Navigator.of(context).push<NoteResult>(
      MaterialPageRoute<NoteResult>(
        builder: (_) => DetailNoteScreen(note: note),
      ),
    );

    if (result == null || !mounted) return;

    final int index = _notes.indexWhere((item) => item.id == note.id);
    if (index == -1) return;

    if (result.deleted) {
      setState(() => _notes.removeAt(index));
      _showSnack('Catatan "${note.title}" telah dihapus.');
      return;
    }

    final Note? updatedNote = result.note;
    if (updatedNote == null) return;

    final bool wasArchived = _notes[index].isArchived;
    setState(() => _notes[index] = updatedNote);

    if (updatedNote.isArchived && !wasArchived) {
      _showSnack('Catatan dipindahkan ke arsip.');
    } else if (!updatedNote.isArchived && wasArchived) {
      _showSnack('Catatan dikembalikan ke beranda.');
    } else {
      _showSnack('Perubahan catatan berhasil disimpan.');
    }
  }

  void _changeTab(int index) {
    FocusScope.of(context).unfocus();
    setState(() => _tabIndex = index);
  }

  void _resetFilter() {
    setState(() {
      _query = '';
      _selectedCategory = null;
      _searchController.clear();
    });
  }

  void _showSnack(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Kamu akan kembali ke halaman login. Data catatan demo akan '
            'dimulai ulang saat masuk kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.note_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: const Text('MyCatatan'),
          content: const Text(
            'Aplikasi catatan harian sederhana untuk menyimpan ide, rencana, '
            'pekerjaan, dan catatan penting dalam satu tempat.\n\n'
            'Versi 1.0.0 • Dibuat dengan Flutter',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).height < 420;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _buildHeader(compact: compact),
                if (_tabIndex != 2) ...[
                  _buildSearchField(compact: compact),
                  CategoryFilter(
                    selected: _selectedCategory,
                    compact: compact,
                    onSelected: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                  SizedBox(height: compact ? 8 : 14),
                ],
                Expanded(child: _buildBody(compact: compact)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: compact ? 60 : null,
        selectedIndex: _tabIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Arsip',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddNote,
              tooltip: 'Tambah catatan',
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded, size: 30),
            )
          : null,
    );
  }

  Widget _buildHeader({required bool compact}) {
    final String greeting;
    final String subtitle;

    switch (_tabIndex) {
      case 1:
        greeting = 'Arsip Catatan';
        subtitle = '${_archivedNotes.length} catatan tersimpan untuk nanti';
        break;
      case 2:
        greeting = 'Profil';
        subtitle = 'Kelola akun dan preferensimu';
        break;
      default:
        greeting = 'Halo, Ahmad! 👋';
        subtitle = 'Apa yang ingin kamu catat hari ini?';
        break;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, compact ? 10 : 18, 20, compact ? 8 : 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: compact ? 20 : null,
                    height: compact ? 1.2 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: compact ? 11 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _changeTab(2),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF60A5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'A',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 15 : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({required bool compact}) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, compact ? 8 : 14),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        style: compact ? textTheme.bodyMedium : null,
        decoration: InputDecoration(
          isDense: compact,
          contentPadding: compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : null,
          hintText: 'Cari catatan...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: compact ? 19 : 22,
          ),
          prefixIconConstraints: compact
              ? const BoxConstraints(minWidth: 38, minHeight: 38)
              : null,
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  padding: compact ? EdgeInsets.zero : null,
                  constraints: compact
                      ? const BoxConstraints(minWidth: 36, minHeight: 36)
                      : null,
                  iconSize: compact ? 18 : null,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: compact ? 18 : 20,
                    color: AppColors.textSecondary,
                  ),
                ),
          suffixIconConstraints: compact
              ? const BoxConstraints(minWidth: 38, minHeight: 38)
              : null,
        ),
      ),
    );
  }

  Widget _buildBody({required bool compact}) {
    if (_tabIndex == 2) return _buildProfileContent();

    final List<Note> notes = _visibleNotes;
    if (notes.isEmpty) return _buildEmptyState();

    final bool showHeader = !compact;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 4, 20, compact ? 100 : 110),
      itemCount: notes.length + (showHeader ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (showHeader && index == 0) return _buildListHeader(notes.length);

        final Note note = notes[showHeader ? index - 1 : index];
        return NoteCard(
          note: note,
          compact: compact,
          onTap: () => _openDetail(note),
        );
      },
    );
  }

  Widget _buildListHeader(int count) {
    final String title;
    if (_hasActiveFilter) {
      title = 'Hasil Pencarian';
    } else if (_tabIndex == 1) {
      title = 'Catatan Diarsipkan';
    } else {
      title = 'Catatan Terbaru';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count catatan',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isArchive = _tabIndex == 1;
    final String title;
    final String message;
    final String buttonLabel;
    final VoidCallback onPressed;

    if (_hasActiveFilter) {
      title = 'Catatan tidak ditemukan';
      message = 'Coba kata kunci lain atau ubah filter kategori.';
      buttonLabel = 'Reset Pencarian & Filter';
      onPressed = _resetFilter;
    } else if (isArchive) {
      title = 'Arsip masih kosong';
      message = 'Catatan yang kamu arsipkan akan muncul di sini.';
      buttonLabel = 'Kembali ke Beranda';
      onPressed = () => _changeTab(0);
    } else {
      title = 'Belum ada catatan';
      message = 'Mulai catat ide pertamamu hari ini.';
      buttonLabel = 'Tambah Catatan';
      onPressed = _openAddNote;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final int importantCount = _activeNotes
        .where((note) => note.category == NoteCategory.penting)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.24),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'A',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahmad Fauzi',
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ahmad.fauzi@email.com',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pengguna Aktif',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontSize: 10.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profil (demo)',
                  onPressed: () => _showSnack(
                    'Halaman edit profil hanya tersedia sebagai demo.',
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.description_outlined,
                  value: '${_activeNotes.length}',
                  label: 'Catatan',
                  color: AppColors.primary,
                  softColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_outline_rounded,
                  value: '$importantCount',
                  label: 'Penting',
                  color: const Color(0xFFD97706),
                  softColor: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  value: '${_archivedNotes.length}',
                  label: 'Arsip',
                  color: const Color(0xFF7C3AED),
                  softColor: const Color(0xFFEDE9FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('Pengaturan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Material(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _ProfileMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Pengingat catatan harian',
                  trailing: Switch.adaptive(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 64),
                _ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang MyCatatan',
                  subtitle: 'Versi 1.0.0',
                  onTap: _showAboutDialog,
                ),
                const Divider(height: 1, indent: 64),
                _ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan & Dukungan',
                  subtitle: 'Pusat bantuan aplikasi',
                  onTap: () =>
                      _showSnack('Butuh bantuan? Hubungi support@mycatatan.id'),
                ),
                const Divider(height: 1, indent: 64),
                _ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  title: 'Keluar',
                  subtitle: 'Kembali ke halaman login',
                  isDanger: true,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'MyCatatan v1.0.0',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  List<Note> _createDummyNotes() {
    final DateTime now = DateTime.now();

    return [
      Note(
        id: '1',
        title: 'Ide Aplikasi',
        content:
            'Membuat aplikasi catatan sederhana dengan tampilan modern, '
            'pencarian cepat, dan pengelompokan berdasarkan kategori. '
            'Fokus pada pengalaman menulis yang nyaman dan tidak mengganggu.',
        category: NoteCategory.penting,
        color: NoteColor.biru,
        priority: NotePriority.tinggi,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Note(
        id: '2',
        title: 'Rencana Mingguan',
        content:
            'Menyusun target mingguan: menyelesaikan desain halaman utama, '
            'rapat tim hari Selasa, dan menyiapkan presentasi progres '
            'untuk hari Jumat.',
        category: NoteCategory.kerja,
        color: NoteColor.hijau,
        priority: NotePriority.sedang,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      Note(
        id: '3',
        title: 'Catatan Kuliah',
        content:
            'Ringkasan materi Struktur Data: stack, queue, dan linked list. '
            'Jangan lupa mengerjakan latihan nomor 4 sampai 8 sebelum '
            'pertemuan berikutnya.',
        category: NoteCategory.kuliah,
        color: NoteColor.kuning,
        priority: NotePriority.sedang,
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      Note(
        id: '4',
        title: 'Hal yang Perlu Dibeli',
        content:
            'Buku catatan baru, pulpen hitam, sticky notes, dan charger '
            'cadangan. Cek juga stok kopi di dapur sebelum akhir pekan.',
        category: NoteCategory.pribadi,
        color: NoteColor.pink,
        priority: NotePriority.rendah,
        createdAt: now.subtract(const Duration(days: 3, hours: 5)),
      ),
      Note(
        id: '5',
        title: 'Jurnal Harian',
        content:
            'Hari ini belajar banyak hal baru tentang Flutter. Mulai '
            'memahami cara kerja widget, state, dan navigasi. Semoga '
            'besok bisa lebih produktif lagi.',
        category: NoteCategory.pribadi,
        color: NoteColor.ungu,
        priority: NotePriority.rendah,
        createdAt: now.subtract(const Duration(days: 4, hours: 2)),
      ),
    ];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isDanger
        ? AppColors.danger
        : AppColors.textPrimary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFEE2E2) : AppColors.accent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isDanger ? AppColors.danger : AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
      ),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
                )),
    );
  }
}
