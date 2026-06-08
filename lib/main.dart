import 'package:flutter/material.dart';
import 'registrase.dart';
import 'perfil.dart';

void main() {
  runApp(const AlojaApp());
}

class AlojaApp extends StatefulWidget {
  const AlojaApp({super.key});

  @override
  State<AlojaApp> createState() => _AlojaAppState();
}

class _AlojaAppState extends State<AlojaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  bool get _isDarkMode => _themeMode == ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALOJA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        useMaterial3: true,
        scaffoldBackgroundColor: kCream,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101418),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101418),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: _themeMode,
      home: AlojaHomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// ─── Color Palette ───────────────────────────────────────────────────────────
const kEmerald = Color(0xFF1B4332);
const kEmeraldMid = Color(0xFF2D6A4F);
const kEmeraldLight = Color(0xFF52B788);
const kSand = Color(0xFFD4A853);
const kSandLight = Color(0xFFF0D080);
const kCream = Color(0xFFF8F4EC);
const kCreamDark = Color(0xFFEDE8DA);
const kTerracotta = Color(0xFFBF6B3D);
const kWhite = Color(0xFFFFFFFF);

bool _isDarkTheme(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
Color _cardBackground(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF192530)
    : kWhite.withValues(alpha: 0.97);
Color _panelBackground(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF15212A)
    : kCream.withValues(alpha: 0.92);
Color _dividerColor(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF2D3B47)
    : kCreamDark;
Color _textPrimary(BuildContext context) => _isDarkTheme(context)
    ? Colors.white
    : kEmerald;
Color _textSecondary(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFFB8CAD4)
    : kEmeraldMid.withValues(alpha: 0.7);
Color _hintColor(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFFA4B7C2)
    : kEmeraldMid.withValues(alpha: 0.5);
Color _searchFieldBackground(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF12212A)
    : kCream;
Color _searchFieldBorder(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF2D3B47)
    : kCreamDark;
Color _accentText(BuildContext context) => _isDarkTheme(context)
    ? const Color(0xFF71E9CC)
    : const Color.fromARGB(255, 83, 212, 180);
Color _cardShadowColor(BuildContext context) => _isDarkTheme(context)
    ? Colors.black.withValues(alpha: 0.35)
    : kEmerald.withValues(alpha: 0.18);

// ─── Data ─────────────────────────────────────────────────────────────────────
String _getWebSafeUrl(String originalUrl) {
  return 'https://images.weserv.nl/?url=${Uri.encodeComponent(originalUrl)}&w=800&fit=cover';
}

final List<Map<String, dynamic>> kDestinations = [
  {
    'city': 'Caracas',
    'region': 'Distrito Capital',
    'price': '\$45/noche',
    'rating': 4.8,
    'tag': 'Oferta',
    'gradient': [Color(0xFF1B4332), Color(0xFF2D6A4F)],
    'image': _getWebSafeUrl('https://www.huelvainformacion.es/2023/06/20/huelva/Explora-capital-Venezuela-Caracas_1804029652_187279712_1200x675.jpg'),
  },
  {
    'city': 'Los Roques',
    'region': 'Dependencias Federales',
    'price': '\$120/noche',
    'rating': 5.0,
    'tag': 'Popular',
    'gradient': [Color(0xFF0077B6), Color(0xFF00B4D8)],
    'image': _getWebSafeUrl('https://elsumario.com/wp-content/uploads/2024/02/Los-Roques-venezuela.jpg'),
  },
  {
    'city': 'Mérida',
    'region': 'Estado Mérida',
    'price': '\$38/noche',
    'rating': 4.6,
    'tag': 'Nuevo',
    'gradient': [Color(0xFF6B4226), Color(0xFFBF6B3D)],
    'image': _getWebSafeUrl('https://i.pinimg.com/originals/e2/c7/af/e2c7afc7725c339858c2347965c5e851.jpg'),
  },
  {
    'city': 'Margarita',
    'region': 'Nueva Esparta',
    'price': '\$75/noche',
    'rating': 4.9,
    'tag': 'Descuento',
    'gradient': [Color(0xFF7B3F00), Color(0xFFD4A853)],
    'image': _getWebSafeUrl('https://tse1.mm.bing.net/th/id/OIP.iWG1J91ZFF-Aog4Nj_jOAgHaEf?rs=1&pid=ImgDetMain&o=7&rm=3'),
  },
];

// ─── Main Page ────────────────────────────────────────────────────────────────
class AlojaHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const AlojaHomePage({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<AlojaHomePage> createState() => _AlojaHomePageState();
}

class _AlojaHomePageState extends State<AlojaHomePage>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardsFade;

  int _selectedNav = 0;
  final List<String> _navItems = ['Inicio', 'Alojamientos', 'Conócenos'];
  bool _isLoggedIn = false;
  String _userFullName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userGender = '';
  String _userBirthday = '';

  String get _userFirstName {
    final name = _userFullName.trim();
    return name.isEmpty ? '' : name.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _cardsFade = CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOut,
    );

    _heroController.forward().then((_) => _cardsController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  Future<void> _openAccount() async {
    if (_isLoggedIn) {
      final result = await Navigator.of(context).push<Map<String, String>>(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userData: {
              'name': _userFullName,
              'email': _userEmail,
              'phone': _userPhone,
              'gender': _userGender,
              'birthday': _userBirthday,
            },
          ),
        ),
      );

if (result != null) {
        // 1. Si el perfil devolvió la acción de cerrar sesión
        if (result['action'] == 'logout') {
          setState(() {
            _isLoggedIn = false;
            _userFullName = '';
            _userEmail = '';
            _userPhone = '';
            _userGender = '';
            _userBirthday = '';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión cerrada correctamente'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          // 2. Si solo editó sus datos, los actualizamos normalmente
          setState(() {
            _userFullName = result['name'] ?? _userFullName;
            _userEmail = result['email'] ?? _userEmail;
            _userPhone = result['phone'] ?? _userPhone;
            _userGender = result['gender'] ?? _userGender;
            _userBirthday = result['birthday'] ?? _userBirthday;
          });
        }
      }
      return;
    }

    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );

    if (result != null) {
      setState(() {
        _isLoggedIn = true;
        _userFullName = result['name'] ?? '';
        _userEmail = result['email'] ?? '';
        _userPhone = result['phone'] ?? '';
        _userGender = result['gender'] ?? '';
        _userBirthday = result['birthday'] ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido, ${_userFirstName.isNotEmpty ? _userFirstName : 'usuario'}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideAppBar = screenWidth > 720;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
         // ── Navigation Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            toolbarHeight: 70,
            titleSpacing: 0,
            title: isWideAppBar
                ? Row(
                    children: [
                      // 1. LOGO EN PANTALLAS GRANDES (Escritorio)
                      Image.network(
                        'https://i.postimg.cc/Zn66zqnm/Logo-aloja-en-png-sin-fondo.png', // <-- Coloca aquí el link de tu logo
                        height: 70, // Altura ajustada para que no rompa la barra
                        fit: BoxFit.contain,
                      ),
                      // Centered navigation
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(_navItems.length, (i) {
                                  final selected = i == _selectedNav;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedNav = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(
                                        _navItems[i],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: selected ? Theme.of(context).colorScheme.onPrimary : _textPrimary(context),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Account button (right)
                      GestureDetector(
                        onTap: _openAccount,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isLoggedIn ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLoggedIn ? Icons.verified_user : Icons.person,
                                color: kWhite,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLoggedIn ? 'Hola, $_userFirstName' : 'Mi Cuenta',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                // 2. LOGO EN PANTALLAS PEQUEÑAS (Móvil)
                : Image.network(
                    'https://i.postimg.cc/Zn66zqnm/Logo-aloja-en-png-sin-fondo.png', // <-- Coloca el mismo link de tu logo aquí
                    height: 32, 
                    fit: BoxFit.contain,
                  ),
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).iconTheme.color ?? _textPrimary(context),
                ),
                tooltip: widget.isDarkMode ? 'Modo diurno' : 'Modo nocturno',
              ),
              if (!isWideAppBar)
                PopupMenuButton<int>(
                  icon: Icon(Icons.menu, color: _textPrimary(context)),
                  onSelected: (index) => setState(() => _selectedNav = index),
                  itemBuilder: (context) => List.generate(
                    _navItems.length,
                    (index) => PopupMenuItem<int>(
                      value: index,
                      child: Text(_navItems[index]),
                    ),
                  ),
                ),
              if (!isWideAppBar)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: _openAccount,
                    icon: Icon(_isLoggedIn ? Icons.verified_user : Icons.person, color: _textPrimary(context)),
                    tooltip: _isLoggedIn ? 'Perfil' : 'Mi Cuenta',
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: _dividerColor(context),
              ),
            ),
          ),

          // ── Hero Section ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(
                position: _heroSlide,
                child: _HeroSection(),
              ),
            ),
          ),

          // ── Section Title ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsFade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destinos Destacados',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Descubre Venezuela a precios accesibles',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary(context),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Ver todos →',
                        style: TextStyle(
                          color: _accentText(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Destination Cards ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsFade,
              child: SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
                  itemCount: kDestinations.length,
                  itemBuilder: (context, i) => _DestinationCard(
                    data: kDestinations[i],
                    delay: i * 100,
                  ),
                ),
              ),
            ),
          ),

          // ── Features Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsFade,
              child: _FeaturesRow(),
            ),
          ),

          // ── CTA Banner ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsFade,
              child: _CTABanner(
                isLoggedIn: _isLoggedIn,       // Le pasamos la variable que controla si está logueado
                onTapRegister: _openAccount,  // Le pasamos la función que abre el registro o perfil
              ),
            ),
          ),

          // Footer space
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatefulWidget {
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _destinoCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _fechaCtrl = TextEditingController();
  final TextEditingController _huespedesCtrl = TextEditingController();
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _destinoCtrl.dispose();
    _precioCtrl.dispose();
    _fechaCtrl.dispose();
    _huespedesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SizedBox(
          height: isWide ? 480 : 560,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient (simulating desert landscape)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [
                            Color(0xFF0D161F),
                            Color(0xFF14222E),
                            Color(0xFF173445),
                            Color(0xFF1F4F62),
                          ]
                        : const [
                            Color.fromARGB(255, 245, 236, 213),
                            Color.fromARGB(255, 188, 233, 236),
                            Color.fromARGB(255, 186, 223, 238),
                            Color.fromARGB(255, 160, 228, 245),
                          ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // Organic sand-dune shapes
              CustomPaint(
                painter: _DunePainter(),
              ),

              // Left panel - brand
              if (isWide)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * 0.38,
                  child: Container(
                    color: _panelBackground(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ALOJA',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary(context),
                              letterSpacing: 10,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 3,
                            width: 48,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tu sitio web de reservas donde podrás descubrir cada rincón de Venezuela a precios accesibles.',
                            style: TextStyle(
                              fontSize: 15,
                              color: _textSecondary(context),
                              height: 1.65,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _StatsBadge(),
                        ],
                      ),
                    ),
                  ),
                ),

              // Right panel - search + card
              Positioned(
                left: isWide ? constraints.maxWidth * 0.38 : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 24 : 16,
                    isWide ? 28 : 16,
                    isWide ? 24 : 16,
                    isWide ? 28 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isWide) ...[
                        const SizedBox(height: 8),
                        Text(
                          'ALOJA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: kWhite,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Search card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardBackground(context),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _cardShadowColor(context),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _SearchField(
                                    label: 'Destino',
                                    hint: '¿A dónde vas?',
                                    icon: Icons.location_on_outlined,
                                    controller: _destinoCtrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SearchField(
                                    label: 'Precios',
                                    hint: 'Presupuesto',
                                    icon: Icons.attach_money,
                                    controller: _precioCtrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SearchField(
                                    label: 'Fecha',
                                    hint: 'dd/mm/aaaa',
                                    icon: Icons.calendar_today_outlined,
                                    controller: _fechaCtrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SearchField(
                                    label: 'Huéspedes',
                                    hint: 'Cantidad de Personas',
                                    icon: Icons.group_outlined,
                                    controller: _huespedesCtrl,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SearchButton(shimmer: _shimmerController),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Featured property card
                      Expanded(
                        child: _FeaturedCard(),
                      ),

                      // Scroll hint
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Text(
                              'Desliza para ver',
                              style: TextStyle(
                                color: kWhite.withValues(alpha: 0.85),
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: kWhite.withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stats Badge ──────────────────────────────────────────────────────────────
class _StatsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(value: '500+', label: 'Alojamientos'),
        Container(width: 1, height: 32, color: _dividerColor(context), margin: const EdgeInsets.symmetric(horizontal: 16)),
        _StatItem(value: '24', label: 'Estados'),
        Container(width: 1, height: 32, color: _dividerColor(context), margin: const EdgeInsets.symmetric(horizontal: 16)),
        _StatItem(value: '4.9★', label: 'Rating'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary(context), fontFamily: 'Georgia')),
        Text(label, style: TextStyle(fontSize: 11, color: _textSecondary(context))),
      ],
    );
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  const _SearchField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _textPrimary(context),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _searchFieldBackground(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _searchFieldBorder(context), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 11,
                color: _hintColor(context),
              ),
              prefixIcon: Icon(icon, size: 15, color: Theme.of(context).colorScheme.secondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Search Button ────────────────────────────────────────────────────────────
class _SearchButton extends StatefulWidget {
  final AnimationController shimmer;
  const _SearchButton({required this.shimmer});

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: widget.shimmer,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hovered
                    ? [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primary]
                    : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: _hovered ? 102 : 51),
                  blurRadius: _hovered ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {},
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Buscar Alojamientos',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Featured Card ────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          
          // 1. IMAGEN DE FONDO (Tu foto de El Ávila)
          Image.network(
            'https://t3.ftcdn.net/jpg/03/61/09/66/240_F_361096616_nuB4VJ10OZGOKxtMI1sbFgSndNj5nFYR.jpg', 
            fit: BoxFit.cover,
          ),

          // 2. Capa de degradado inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF0C161F).withValues(alpha: 242)
                        : kWhite.withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),

          // 3. Text overlay (¡Ya limpiado sin el botón de arriba!)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Aumenté un pelín el espacio inferior (de 12 a 16) para que respire mejor
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alojamientos en Descuento',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Destination Card ─────────────────────────────────────────────────────────
class _DestinationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int delay;

  const _DestinationCard({required this.data, required this.delay});

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: List<Color>.from(d['gradient']),
              ),
              image: d['image'] != null
                  ? DecorationImage(
                      image: d['image'] is String && (d['image'] as String).startsWith('http')
                          ? NetworkImage(d['image'] as String)
                          : AssetImage(d['image'] as String) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        kWhite.withValues(alpha: 56),
                        BlendMode.dstATop,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (d['gradient'][0] as Color).withValues(alpha: 0.4),
                  blurRadius: _hovered ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kWhite.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 60,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kWhite.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kWhite.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d['tag'] as String,
                          style: const TextStyle(
                            color: kWhite,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        d['city'] as String,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          color: kWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d['region'] as String,
                        style: TextStyle(
                          color: kWhite.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d['price'] as String,
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: kSandLight, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '${d['rating']}',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Features Row ─────────────────────────────────────────────────────────────
class _FeaturesRow extends StatelessWidget {
  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.verified_outlined,
      'title': 'Verificados',
      'desc': 'Todos los alojamientos son revisados y aprobados',
    },
    {
      'icon': Icons.support_agent,
      'title': 'Soporte 24/7',
      'desc': 'Atención al cliente disponible todo el día',
    },
    {
      'icon': Icons.price_check,
      'title': 'Mejor Precio',
      'desc': 'Garantizamos las mejores tarifas disponibles',
    },
    {
      'icon': Icons.cancel_outlined,
      'title': 'Cancelación Gratis',
      'desc': 'Cancela sin cargos hasta 24h antes',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 32, 28, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kEmerald,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: _features
            .map(
              (f) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kWhite.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          f['icon'] as IconData,
                          color: kSandLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        f['title'] as String,
                        style: const TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f['desc'] as String,
                        style: TextStyle(
                          color: kWhite.withValues(alpha: 0.65),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── CTA Banner ───────────────────────────────────────────────────────────────
class _CTABanner extends StatelessWidget {
  final bool isLoggedIn; // Recibe si está logueado
  final VoidCallback onTapRegister; // Recibe la función unificada _openAccount

  const _CTABanner({
    required this.isLoggedIn,
    required this.onTapRegister,
  });

  @override
  Widget build(BuildContext context) {
    // Si ya inició sesión o se registró, NO dibuja nada en la pantalla
    if (isLoggedIn) {
      return const SizedBox.shrink(); // Widget invisible que ocupa cero espacio
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A853), Color(0xFFBF6B3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kSand.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Listo para explorar\nVenezuela?',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kWhite,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Regístrate y obtén 20% de descuento en tu primera reserva.',
                  style: TextStyle(
                    color: kWhite.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            // Al hacer clic, ejecuta la acción centralizada de main.dart
            onPressed: onTapRegister, 
            style: ElevatedButton.styleFrom(
              backgroundColor: kWhite,
              foregroundColor: kTerracotta,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Registrarse',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────
class _DunePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFE8C97A).withValues(alpha: 0.4),
          const Color(0xFFD4854A).withValues(alpha: 0.0),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.35,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFBF6B3D).withValues(alpha: 0.15);

    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.9,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2D6A4F).withValues(alpha: 0.55);

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.15, size.height * 0.35)
      ..lineTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.4, size.height * 0.28)
      ..lineTo(size.width * 0.55, size.height * 0.48)
      ..lineTo(size.width * 0.68, size.height * 0.3)
      ..lineTo(size.width * 0.82, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Lighter layer
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF52B788).withValues(alpha: 0.35);

    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.12, size.height * 0.50)
      ..lineTo(size.width * 0.25, size.height * 0.62)
      ..lineTo(size.width * 0.38, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.58)
      ..lineTo(size.width * 0.62, size.height * 0.44)
      ..lineTo(size.width * 0.75, size.height * 0.60)
      ..lineTo(size.width * 0.88, size.height * 0.50)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1B4332).withOpacity(0.7);

    // Simple city blocks
    final buildings = [
      [0.05, 0.78, 0.04, 0.15],
      [0.1, 0.72, 0.05, 0.21],
      [0.16, 0.80, 0.03, 0.13],
      [0.2, 0.68, 0.04, 0.25],
      [0.25, 0.74, 0.06, 0.19],
      [0.32, 0.76, 0.04, 0.17],
      [0.37, 0.65, 0.05, 0.28],
      [0.43, 0.72, 0.05, 0.21],
      [0.49, 0.78, 0.04, 0.15],
      [0.54, 0.70, 0.06, 0.23],
      [0.61, 0.75, 0.04, 0.18],
      [0.66, 0.67, 0.05, 0.26],
      [0.72, 0.73, 0.04, 0.20],
      [0.77, 0.79, 0.05, 0.14],
      [0.83, 0.71, 0.04, 0.22],
      [0.88, 0.76, 0.05, 0.17],
      [0.94, 0.80, 0.04, 0.13],
    ];

    for (final b in buildings) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * b[0],
          size.height * b[1],
          size.width * b[2],
          size.height * b[3],
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}