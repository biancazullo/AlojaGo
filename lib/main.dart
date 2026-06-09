// lib/main.dart
// CAMBIOS vs original:
// 1. _userRole guardado en estado global
// 2. _openAccount devuelve el rol desde toProfileMap()
// 3. Botón "Panel [Rol]" en AppBar cuando está logueado
// 4. Rutas a TravelerDashboard / OperatorDashboard / AdminDashboard

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/repositories/auth_repository.dart';
import 'domain/models/app_user.dart';
import 'domain/models/listing.dart';
import 'firebase_options.dart';
import 'perfil.dart';
import 'registrase.dart';
import 'ui/features/admin/admin_dashboard.dart';
import 'ui/features/operator/operator_dashboard.dart';
import 'ui/features/traveler/traveler_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AlojaApp());
}

class AlojaApp extends StatefulWidget {
  const AlojaApp({super.key, this.authRepository});
  final AuthRepository? authRepository;

  @override
  State<AlojaApp> createState() => _AlojaAppState();
}

class _AlojaAppState extends State<AlojaApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late final AuthRepository _authRepository;

  bool get _isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? FirebaseAuthRepository();
  }

  void _toggleTheme() => setState(
    () => _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALOJA',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kEmerald),
        useMaterial3: true,
        scaffoldBackgroundColor: kCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: kCream,
          foregroundColor: kEmerald,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kEmeraldLight,
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
      home: AlojaHomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
        authRepository: _authRepository,
      ),
    );
  }
}

const kEmerald = Color(0xFF1B4332);
const kEmeraldMid = Color(0xFF2D6A4F);
const kEmeraldLight = Color(0xFF52B788);
const kSand = Color(0xFFD4A853);
const kCream = Color(0xFFF8F4EC);
const kTerracotta = Color(0xFFBF6B3D);

String _imageProxy(String url) =>
    'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&w=900&fit=cover';

final List<AlojaListing> _seedListings = [
  AlojaListing(
    id: 'caracas-altamira',
    ownerId: 'host-1',
    title: 'Apartamento ejecutivo en Altamira',
    city: 'Caracas',
    region: 'Distrito Capital',
    nightlyPrice: 45,
    maxGuests: 3,
    imageUrl: _imageProxy(
      'https://www.huelvainformacion.es/2023/06/20/huelva/Explora-capital-Venezuela-Caracas_1804029652_187279712_1200x675.jpg',
    ),
    tag: 'Oferta',
    rating: 4.8,
    status: ListingStatus.active,
    maxReservations: 10,
    accommodationType: 'Apartamento',
    category: 'Estándar',
    reviews: const [
      ListingReview(author: 'Mariana', rating: 5, comment: 'Muy buena ubicacion y check-in rapido.'),
    ],
  ),
  AlojaListing(
    id: 'posada-roques',
    ownerId: 'host-2',
    title: 'Posada frente al mar',
    city: 'Los Roques',
    region: 'Dependencias Federales',
    nightlyPrice: 120,
    maxGuests: 4,
    imageUrl: _imageProxy('https://elsumario.com/wp-content/uploads/2024/02/Los-Roques-venezuela.jpg'),
    tag: 'Popular',
    rating: 5,
    status: ListingStatus.active,
    maxReservations: 5,
    accommodationType: 'Posada',
    category: 'Premium',
    reviews: const [
      ListingReview(author: 'Carlos', rating: 5, comment: 'Vista excelente y anfitriones atentos.'),
    ],
  ),
  AlojaListing(
    id: 'cabana-merida',
    ownerId: 'host-3',
    title: 'Cabana andina familiar',
    city: 'Merida',
    region: 'Estado Merida',
    nightlyPrice: 38,
    maxGuests: 5,
    imageUrl: _imageProxy('https://i.pinimg.com/originals/e2/c7/af/e2c7afc7725c339858c2347965c5e851.jpg'),
    tag: 'Nuevo',
    rating: 4.6,
    status: ListingStatus.active,
    maxReservations: 0,
    accommodationType: 'Cabaña',
    category: 'Estándar',
    reviews: const [
      ListingReview(author: 'Valeria', rating: 4, comment: 'Comoda para viajar en familia.'),
    ],
  ),
  AlojaListing(
    id: 'margarita-playa',
    ownerId: 'host-4',
    title: 'Casa cerca de Playa El Agua',
    city: 'Margarita',
    region: 'Nueva Esparta',
    nightlyPrice: 75,
    maxGuests: 6,
    imageUrl: _imageProxy(
      'https://tse1.mm.bing.net/th/id/OIP.iWG1J91ZFF-Aog4Nj_jOAgHaEf?rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    tag: 'Descuento',
    rating: 4.9,
    status: ListingStatus.active,
    maxReservations: 8,
    accommodationType: 'Hotel',
    category: 'Lujo',
    reviews: const [
      ListingReview(author: 'Diego', rating: 5, comment: 'Ideal para una escapada de fin de semana.'),
    ],
  ),
];

// ── HOME PAGE ──────────────────────────────────────────────────────────────
class AlojaHomePage extends StatefulWidget {
  const AlojaHomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.authRepository,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final AuthRepository authRepository;

  @override
  State<AlojaHomePage> createState() => _AlojaHomePageState();
}

class _AlojaHomePageState extends State<AlojaHomePage> {
  final _destinationController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _guestsController = TextEditingController();
  final _scrollController = ScrollController();

  late List<AlojaListing> _listings;
  int _selectedNav = 0;

  // ── Estado de sesión ──
  bool _isLoggedIn = false;
  String _userId = '';
  String _userFullName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userGender = '';
  String _userBirthday = '';
  UserRole _userRole = UserRole.traveler;

  String get _userFirstName {
    final name = _userFullName.trim();
    return name.isEmpty ? '' : name.split(' ').first;
  }

  List<AlojaListing> get _filteredListings {
    final maxPrice = int.tryParse(_maxPriceController.text.trim());
    final guests = int.tryParse(_guestsController.text.trim());
    return _listings
        .where(
          (l) => l.matchesSearch(
            destination: _destinationController.text,
            maxPrice: maxPrice,
            guests: guests,
          ),
        )
        .toList();
  }

  List<AlojaListing> get _myListings =>
      _listings.where((l) => l.ownerId == _userId).toList();

  @override
  void initState() {
    super.initState();
    _listings = [..._seedListings];
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _maxPriceController.dispose();
    _guestsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Login / Registro ───────────────────────────────────────────────────
  Future<void> _openAccount() async {
    if (_isLoggedIn) {
      final result = await Navigator.of(context).push<Map<String, String>>(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            authRepository: widget.authRepository,
            userData: {
              'id': _userId,
              'name': _userFullName,
              'email': _userEmail,
              'phone': _userPhone,
              'gender': _userGender,
              'birthday': _userBirthday,
              'role': _userRole.name,
            },
          ),
        ),
      );
      if (!mounted || result == null) return;
      if (result['action'] == 'logout') {
        setState(() {
          _isLoggedIn = false;
          _userId = '';
          _userFullName = '';
          _userEmail = '';
          _userPhone = '';
          _userGender = '';
          _userBirthday = '';
          _userRole = UserRole.traveler;
        });
        _showMessage('Sesion cerrada correctamente');
      } else {
        setState(() {
          _userFullName = result['name'] ?? _userFullName;
          _userId = result['id'] ?? _userId;
          _userEmail = result['email'] ?? _userEmail;
          _userPhone = result['phone'] ?? _userPhone;
          _userGender = result['gender'] ?? _userGender;
          _userBirthday = result['birthday'] ?? _userBirthday;
        });
      }
      return;
    }

    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (context) =>
            RegisterPage(authRepository: widget.authRepository),
      ),
    );
    if (!mounted || result == null) return;

    final roleStr = result['role'] ?? 'traveler';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.traveler,
    );

    setState(() {
      _isLoggedIn = true;
      _userId = result['id'] ?? '';
      _userFullName = result['name'] ?? '';
      _userEmail = result['email'] ?? '';
      _userPhone = result['phone'] ?? '';
      _userGender = result['gender'] ?? '';
      _userBirthday = result['birthday'] ?? '';
      _userRole = role;
    });
    _showMessage(
      'Bienvenido, ${_userFirstName.isEmpty ? 'usuario' : _userFirstName}',
    );
  }

  // ── Abrir panel según rol ─────────────────────────────────────────────
  void _openRoleDashboard() {
    if (!_isLoggedIn) return;
    final currentUser = AppUser(
      id: _userId,
      name: _userFullName,
      email: _userEmail,
      phone: _userPhone,
      gender: _userGender,
      birthday: _userBirthday,
      role: _userRole,
    );

    switch (_userRole) {
      case UserRole.traveler:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TravelerDashboard(
              user: currentUser,
              listings: _listings,
              onReserve: (listing, nights) async {
                await _openPaymentFlow(listing, nights: nights);
                return true;
              },
              onReview: (listing) => _openReviewDialog(listing),
            ),
          ),
        );
        break;

      case UserRole.operator:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OperatorDashboard(
              user: currentUser,
              allListings: _listings,
              onSaveListing: (listing) {
                setState(() {
                  final idx =
                      _listings.indexWhere((l) => l.id == listing.id);
                  if (idx == -1) {
                    _listings.insert(0, listing);
                  } else {
                    _listings[idx] = listing;
                  }
                });
              },
              onDeleteListing: (listing) {
                setState(
                  () => _listings.removeWhere((l) => l.id == listing.id),
                );
              },
              onToggleStatus: _toggleListingStatus,
            ),
          ),
        );
        break;

      case UserRole.admin:
        // Lista simulada de usuarios para el admin
        final mockUsers = [
          currentUser,
          const AppUser(
            id: 'u2',
            name: 'Ana Torres',
            email: 'ana@correo.unimet.edu.ve',
            role: UserRole.traveler,
          ),
          const AppUser(
            id: 'u3',
            name: 'Pedro López',
            email: 'pedro@correo.unimet.edu.ve',
            role: UserRole.operator,
          ),
        ];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              admin: currentUser,
              allUsers: mockUsers,
              allListings: _listings,
              onUpdateUser: (_) {},
              onSaveListing: (listing) {
                setState(() {
                  final idx =
                      _listings.indexWhere((l) => l.id == listing.id);
                  if (idx == -1) {
                    _listings.insert(0, listing);
                  } else {
                    _listings[idx] = listing;
                  }
                });
              },
              onDeleteListing: (listing) {
                setState(
                  () => _listings.removeWhere((l) => l.id == listing.id),
                );
              },
            ),
          ),
        );
        break;

      default:
        break;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _runSearch() {
    setState(() => _selectedNav = 1);
    _scrollController.animateTo(
      540,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openListingForm({AlojaListing? listing}) async {
    if (!_isLoggedIn) {
      await _openAccount();
      if (!mounted || !_isLoggedIn) return;
    }

    final titleController = TextEditingController(text: listing?.title ?? '');
    final cityController = TextEditingController(text: listing?.city ?? '');
    final regionController = TextEditingController(text: listing?.region ?? '');
    final priceController =
        TextEditingController(text: listing?.nightlyPrice.toString() ?? '');
    final guestsController =
        TextEditingController(text: listing?.maxGuests.toString() ?? '');
    final imageController =
        TextEditingController(text: listing?.imageUrl ?? '');
    final maxResController =
        TextEditingController(text: listing?.maxReservations.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<AlojaListing>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(listing == null ? 'Nueva publicacion' : 'Editar publicacion'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogField(controller: titleController, label: 'Titulo'),
                    _DialogField(controller: cityController, label: 'Ciudad'),
                    _DialogField(controller: regionController, label: 'Region'),
                    _DialogField(
                      controller: priceController,
                      label: 'Precio por noche',
                      keyboardType: TextInputType.number,
                    ),
                    _DialogField(
                      controller: guestsController,
                      label: 'Huespedes maximos',
                      keyboardType: TextInputType.number,
                    ),
                    _DialogField(
                      controller: maxResController,
                      label: 'Cantidad max. de reservas (0 = sin limite)',
                      keyboardType: TextInputType.number,
                    ),
                    _DialogField(
                      controller: imageController,
                      label: 'URL de imagen',
                      validator: (_) => null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final next = AlojaListing(
                  id: listing?.id ??
                      'listing-${DateTime.now().microsecondsSinceEpoch}',
                  ownerId: _userId,
                  title: titleController.text.trim(),
                  city: cityController.text.trim(),
                  region: regionController.text.trim(),
                  nightlyPrice: int.parse(priceController.text.trim()),
                  maxGuests: int.parse(guestsController.text.trim()),
                  imageUrl: imageController.text.trim().isEmpty
                      ? _seedListings.first.imageUrl
                      : imageController.text.trim(),
                  tag: listing?.tag ?? 'Anfitrion',
                  rating: listing?.rating ?? 0,
                  reviews: listing?.reviews ?? const [],
                  status: listing?.status ?? ListingStatus.pendingApproval,
                  maxReservations:
                      int.tryParse(maxResController.text.trim()) ?? 0,
                  currentReservations: listing?.currentReservations ?? 0,
                );
                Navigator.pop(context, next);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    for (final c in [
      titleController, cityController, regionController,
      priceController, guestsController, imageController, maxResController
    ]) {
      c.dispose();
    }

    if (saved == null) return;
    setState(() {
      final index = _listings.indexWhere((item) => item.id == saved.id);
      if (index == -1) {
        _listings.insert(0, saved);
      } else {
        _listings[index] = saved;
      }
    });
    _showMessage('Publicacion guardada');
  }

  void _toggleListingStatus(AlojaListing listing) {
    setState(() {
      final index = _listings.indexWhere((item) => item.id == listing.id);
      final nextStatus = listing.status == ListingStatus.active
          ? ListingStatus.paused
          : ListingStatus.active;
      _listings[index] = listing.copyWith(status: nextStatus);
    });
  }

  void _deleteListing(AlojaListing listing) {
    setState(() => _listings.removeWhere((item) => item.id == listing.id));
    _showMessage('Publicacion eliminada');
  }

  Future<void> _openPaymentFlow(AlojaListing listing, {int nights = 2}) async {
    if (!_isLoggedIn) {
      await _openAccount();
      if (!mounted || !_isLoggedIn) return;
    }
    await _openPayment(listing, initialNights: nights);
  }

  Future<void> _openPayment(
    AlojaListing listing, {
    int initialNights = 2,
  }) async {
    if (!_isLoggedIn) {
      await _openAccount();
      if (!mounted || !_isLoggedIn) return;
    }

    if (!listing.hasAvailability) {
      _showMessage('No hay disponibilidad para este alojamiento');
      return;
    }

    final nightsController =
        TextEditingController(text: initialNights.toString());
    String method = 'Tarjeta';
    final paid = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final nights = int.tryParse(nightsController.text) ?? 1;
            final total = listing.nightlyPrice * nights.clamp(1, 60);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmar reserva',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${listing.title} - ${listing.priceLabel}'),
                  if (listing.maxReservations > 0)
                    Text(
                      'Disponibilidad: ${listing.availableSlots} lugares restantes',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nightsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Noches',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    decoration: const InputDecoration(
                      labelText: 'Metodo de pago',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Tarjeta',
                        child: Text('Tarjeta'),
                      ),
                      DropdownMenuItem(
                        value: 'Pago movil',
                        child: Text('Pago movil'),
                      ),
                      DropdownMenuItem(
                        value: 'Transferencia',
                        child: Text('Transferencia'),
                      ),
                    ],
                    onChanged: (v) => setSheetState(() => method = v ?? method),
                  ),
                  const SizedBox(height: 16),
                  _PaymentSummary(total: total, method: method),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.lock_outline),
                      label: Text('Pagar \$${total.toString()}'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    nightsController.dispose();

    if (paid != true) return;

    // Incrementar contador de reservas
    setState(() {
      final idx = _listings.indexWhere((l) => l.id == listing.id);
      if (idx != -1 && _listings[idx].maxReservations > 0) {
        _listings[idx] = _listings[idx].copyWith(
          currentReservations: _listings[idx].currentReservations + 1,
        );
      }
    });

    _showMessage('Pago aprobado. Reserva creada.');
    await _openReviewDialog(listing);
  }

  Future<void> _openReviewDialog(AlojaListing listing) async {
    final commentController = TextEditingController();
    int rating = 5;

    final review = await showDialog<ListingReview>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Dejar comentario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        tooltip: '$value estrellas',
                        onPressed: () =>
                            setDialogState(() => rating = value),
                        icon: Icon(
                          value <= rating ? Icons.star : Icons.star_border,
                          color: kSand,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Omitir'),
                ),
                FilledButton(
                  onPressed: () {
                    final comment = commentController.text.trim();
                    if (comment.isEmpty) return;
                    Navigator.pop(
                      context,
                      ListingReview(
                        author:
                            _userFirstName.isEmpty ? 'Usuario' : _userFirstName,
                        rating: rating,
                        comment: comment,
                      ),
                    );
                  },
                  child: const Text('Publicar'),
                ),
              ],
            );
          },
        );
      },
    );
    commentController.dispose();

    if (review == null) return;
    setState(() {
      final index = _listings.indexWhere((item) => item.id == listing.id);
      _listings[index] = _listings[index].addReview(review);
    });
    _showMessage('Comentario publicado');
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = _filteredListings;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _AlojaAppBar(
            selectedNav: _selectedNav,
            isDarkMode: widget.isDarkMode,
            isLoggedIn: _isLoggedIn,
            userFirstName: _userFirstName,
            userRole: _userRole,
            onToggleTheme: widget.onToggleTheme,
            onAccountTap: _openAccount,
            onRoleDashboardTap: _openRoleDashboard,
            onNavTap: (index) => setState(() => _selectedNav = index),
          ),
          SliverToBoxAdapter(
            child: _HeroSection(
              destinationController: _destinationController,
              maxPriceController: _maxPriceController,
              guestsController: _guestsController,
              onSearch: _runSearch,
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Alojamientos disponibles',
              subtitle: '${filteredListings.length} resultados filtrados',
              actionLabel: 'Nueva publicacion',
              onAction: () => _openListingForm(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            sliver: SliverGrid.builder(
              itemCount: filteredListings.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 480,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
              ),
              itemBuilder: (context, index) {
                final listing = filteredListings[index];
                return _ListingCard(
                  listing: listing,
                  isOwner: listing.ownerId == _userId,
                  onReserve: () => _openPayment(listing),
                  onReview: () => _openReviewDialog(listing),
                  onEdit: () => _openListingForm(listing: listing),
                  onToggleStatus: () => _toggleListingStatus(listing),
                  onDelete: () => _deleteListing(listing),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _HostPanel(
              isLoggedIn: _isLoggedIn,
              listings: _myListings,
              onCreate: () => _openListingForm(),
              onLogin: _openAccount,
              onEdit: (listing) => _openListingForm(listing: listing),
              onToggleStatus: _toggleListingStatus,
              onDelete: _deleteListing,
            ),
          ),
          SliverToBoxAdapter(
            child: _FeaturesBand(totalListings: _listings.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── APP BAR ────────────────────────────────────────────────────────────────
class _AlojaAppBar extends StatelessWidget {
  const _AlojaAppBar({
    required this.selectedNav,
    required this.isDarkMode,
    required this.isLoggedIn,
    required this.userFirstName,
    required this.userRole,
    required this.onToggleTheme,
    required this.onAccountTap,
    required this.onRoleDashboardTap,
    required this.onNavTap,
  });

  final int selectedNav;
  final bool isDarkMode;
  final bool isLoggedIn;
  final String userFirstName;
  final UserRole userRole;
  final VoidCallback onToggleTheme;
  final VoidCallback onAccountTap;
  final VoidCallback onRoleDashboardTap;
  final ValueChanged<int> onNavTap;

  String get _roleLabel {
    switch (userRole) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.operator:
        return 'Operador';
      default:
        return 'Viajero';
    }
  }

  IconData get _roleIcon {
    switch (userRole) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.operator:
        return Icons.business;
      default:
        return Icons.backpack;
    }
  }

  @override
  Widget build(BuildContext context) {
    const navItems = ['Inicio', 'Busqueda', 'Publicaciones'];
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Row(
        children: [
          const Text(
            'ALOJA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: kEmerald,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(navItems.length, (index) {
                  final selected = selectedNav == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(navItems[index]),
                      selected: selected,
                      onSelected: (_) => onNavTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
        ),
        if (isLoggedIn) ...[
          // Botón de panel según rol
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: onRoleDashboardTap,
              icon: Icon(_roleIcon, size: 16),
              label: Text('Panel $_roleLabel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kEmerald,
                side: const BorderSide(color: kEmerald),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: FilledButton.icon(
            onPressed: onAccountTap,
            icon: Icon(isLoggedIn ? Icons.verified_user : Icons.person),
            label: Text(isLoggedIn ? 'Hola, $userFirstName' : 'Mi cuenta'),
          ),
        ),
      ],
    );
  }
}

// ── HERO SECTION (sin cambios) ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.destinationController,
    required this.maxPriceController,
    required this.guestsController,
    required this.onSearch,
  });

  final TextEditingController destinationController;
  final TextEditingController maxPriceController;
  final TextEditingController guestsController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEBF6F1), Color(0xFFFFF5DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 780;
              final intro = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reservas y alojamientos en Venezuela',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: kEmerald,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Busca por destino, compara precios, paga tu reserva y deja feedback despues de tu estadia.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: kEmeraldMid,
                      height: 1.45,
                    ),
                  ),
                ],
              );
              final searchPanel = _SearchPanel(
                destinationController: destinationController,
                maxPriceController: maxPriceController,
                guestsController: guestsController,
                onSearch: onSearch,
              );
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [intro, const SizedBox(height: 24), searchPanel],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: intro),
                  const SizedBox(width: 28),
                  Expanded(flex: 4, child: searchPanel),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.destinationController,
    required this.maxPriceController,
    required this.guestsController,
    required this.onSearch,
  });

  final TextEditingController destinationController;
  final TextEditingController maxPriceController;
  final TextEditingController guestsController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchInput(
              controller: destinationController,
              label: 'Destino',
              icon: Icons.location_on_outlined,
              hint: 'Caracas, Merida, Margarita...',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SearchInput(
                    controller: maxPriceController,
                    label: 'Precio max.',
                    icon: Icons.attach_money,
                    hint: '80',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SearchInput(
                    controller: guestsController,
                    label: 'Huespedes',
                    icon: Icons.group_outlined,
                    hint: '2',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Buscar alojamientos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_home_work_outlined),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isOwner,
    required this.onReserve,
    required this.onReview,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final AlojaListing listing;
  final bool isOwner;
  final VoidCallback onReserve;
  final VoidCallback onReview;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  listing.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: kEmeraldMid,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Chip(
                  label: Text(listing.tag),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                ),
              ),
              if (listing.maxReservations > 0 && !listing.hasAvailability)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Chip(
                    label: const Text('Agotado'),
                    backgroundColor: Colors.red,
                    labelStyle: const TextStyle(color: Colors.white),
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${listing.city}, ${listing.region}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _InlineMetric(
                      icon: Icons.star,
                      value: listing.rating.toStringAsFixed(1),
                      iconColor: kSand,
                    ),
                    _InlineMetric(
                      icon: Icons.group_outlined,
                      value: listing.maxGuests.toString(),
                    ),
                    Text(
                      listing.priceLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (listing.maxReservations > 0)
                      _InlineMetric(
                        icon: Icons.confirmation_num_outlined,
                        value:
                            '${listing.availableSlots} disp.',
                        iconColor: listing.hasAvailability
                            ? Colors.green
                            : Colors.red,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: listing.reviews.isEmpty
                      ? const Text('Sin comentarios todavia')
                      : Text(
                          '"${listing.reviews.last.comment}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: listing.hasAvailability ? onReserve : null,
                        icon: const Icon(Icons.credit_card),
                        label: Text(
                          listing.hasAvailability ? 'Reservar' : 'Agotado',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onReview,
                      icon: const Icon(Icons.rate_review_outlined),
                      tooltip: 'Comentar',
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        tooltip: 'Gestionar publicacion',
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit();
                              break;
                            case 'status':
                              onToggleStatus();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
                            value: 'status',
                            child: Text(
                              listing.status == ListingStatus.active
                                  ? 'Pausar'
                                  : 'Activar',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
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
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.icon, required this.value, this.iconColor});
  final IconData icon;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 3),
        Text(value),
      ],
    );
  }
}

class _HostPanel extends StatelessWidget {
  const _HostPanel({
    required this.isLoggedIn,
    required this.listings,
    required this.onCreate,
    required this.onLogin,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final bool isLoggedIn;
  final List<AlojaListing> listings;
  final VoidCallback onCreate;
  final VoidCallback onLogin;
  final ValueChanged<AlojaListing> onEdit;
  final ValueChanged<AlojaListing> onToggleStatus;
  final ValueChanged<AlojaListing> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gestiona tus publicaciones',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.icon(
                onPressed: isLoggedIn ? onCreate : onLogin,
                icon: Icon(isLoggedIn ? Icons.add : Icons.login),
                label: Text(
                  isLoggedIn ? 'Crear publicacion' : 'Iniciar registro',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isLoggedIn)
            const Text('Registrate para administrar alojamientos propios.')
          else if (listings.isEmpty)
            const Text('Aun no tienes publicaciones creadas.')
          else
            ...listings.map(
              (listing) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  listing.status == ListingStatus.active
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                title: Text(listing.title),
                subtitle: Text(
                  '${listing.status == ListingStatus.active ? 'Activa' : 'Pausada'} - ${listing.priceLabel}',
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      onPressed: () => onEdit(listing),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () => onToggleStatus(listing),
                      icon: const Icon(Icons.pause_circle_outline),
                    ),
                    IconButton(
                      onPressed: () => onDelete(listing),
                      icon: const Icon(Icons.delete_outline),
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

class _FeaturesBand extends StatelessWidget {
  const _FeaturesBand({required this.totalListings});
  final int totalListings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kEmerald,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 18,
        children: [
          _Metric(value: '$totalListings', label: 'publicaciones'),
          const _Metric(value: '3', label: 'roles de usuario'),
          const _Metric(value: '100%', label: 'pago simulado'),
          const _Metric(value: '5★', label: 'feedback y calificacion'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.total, required this.method});
  final int total;
  final String method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined),
          const SizedBox(width: 10),
          Expanded(child: Text('Metodo: $method')),
          Text(
            'Total: \$$total',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo requerido';
              }
              if (keyboardType == TextInputType.number &&
                  int.tryParse(value.trim()) == null) {
                return 'Ingresa un numero valido';
              }
              return null;
            },
      ),
    );
  }
}
