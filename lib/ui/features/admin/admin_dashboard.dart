// lib/ui/features/admin/admin_dashboard.dart
// Panel del Administrador: gestión de usuarios, ofertas, mantenimiento,
// moderación, métricas, modificación de PINs.

import 'package:flutter/material.dart';

import '../../../data/services/operator_request_service.dart';
import '../../../data/services/pin_service.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/listing.dart';
import '../../../domain/models/operator_request.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.admin,
    required this.allUsers,
    required this.allListings,
    required this.onUpdateUser,
    required this.onSaveListing,
    required this.onDeleteListing,
  });

  final AppUser admin;
  final List<AppUser> allUsers;
  final List<AlojaListing> allListings;
  final void Function(AppUser user) onUpdateUser;
  final void Function(AlojaListing listing) onSaveListing;
  final void Function(AlojaListing listing) onDeleteListing;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pinService = PinService();
  final _operatorRequestService = OperatorRequestService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 20),
            const SizedBox(width: 8),
            Text('Admin · ${widget.admin.firstName}'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Panel'),
            Tab(icon: Icon(Icons.assignment_ind_outlined), text: 'Solicitudes'),
            Tab(icon: Icon(Icons.people_outlined), text: 'Usuarios'),
            Tab(icon: Icon(Icons.home_work_outlined), text: 'Posadas'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'Config.'),
            Tab(icon: Icon(Icons.pin_outlined), text: 'PINs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MetricsDashboard(
            totalUsers: widget.allUsers.length,
            totalListings: widget.allListings.length,
            activeListings: widget.allListings
                .where((l) => l.status == ListingStatus.active)
                .length,
            pendingListings: widget.allListings
                .where((l) => l.status == ListingStatus.pendingApproval)
                .length,
          ),
          _OperatorRequestsTab(requestService: _operatorRequestService),
          _UsersTab(users: widget.allUsers, onUpdateUser: widget.onUpdateUser),
          _ListingsAdminTab(
            listings: widget.allListings,
            onApprove: (l) =>
                widget.onSaveListing(l.copyWith(status: ListingStatus.active)),
            onReject: (l) => widget.onSaveListing(
              l.copyWith(status: ListingStatus.rejected),
            ),
            onEdit: (l) => _openEditListing(context, l),
            onDelete: widget.onDeleteListing,
          ),
          const _MaintenanceTab(),
          _PinManagementTab(pinService: _pinService),
        ],
      ),
    );
  }

  Future<void> _openEditListing(
    BuildContext context,
    AlojaListing listing,
  ) async {
    final titleC = TextEditingController(text: listing.title);
    final priceC = TextEditingController(text: listing.nightlyPrice.toString());
    final maxResC = TextEditingController(
      text: listing.maxReservations.toString(),
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<AlojaListing>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar oferta (Admin)'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _adminField(titleC, 'Título'),
              _adminField(priceC, 'Precio/noche', type: TextInputType.number),
              _adminField(
                maxResC,
                'Máx. reservas (0=sin límite)',
                type: TextInputType.number,
              ),
            ],
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
              Navigator.pop(
                context,
                listing.copyWith(
                  title: titleC.text.trim(),
                  nightlyPrice: int.parse(priceC.text.trim()),
                  maxReservations: int.tryParse(maxResC.text.trim()) ?? 0,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    for (final c in [titleC, priceC, maxResC]) {
      c.dispose();
    }
    if (saved != null) {
      widget.onSaveListing(saved);
    }
  }
}

class _OperatorRequestsTab extends StatelessWidget {
  const _OperatorRequestsTab({required this.requestService});

  final OperatorRequestService requestService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OperatorRequest>>(
      stream: requestService.watchRequests(),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? const <OperatorRequest>[];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (requests.isEmpty) {
          return const Center(child: Text('No hay solicitudes de operador'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final isPending = request.status == OperatorRequestStatus.pending;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPending
                      ? const Color(0xFFD4A853)
                      : const Color(0xFFE2E6D7),
                  child: Icon(
                    isPending
                        ? Icons.pending_actions
                        : request.status == OperatorRequestStatus.approved
                        ? Icons.check
                        : Icons.close,
                    color: isPending ? Colors.white : const Color(0xFF1B4332),
                  ),
                ),
                title: Text(request.email),
                subtitle: Text(
                  '${request.name} · ${_requestStatusLabel(request.status)}',
                ),
                trailing: isPending
                    ? Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () => _approveRequest(context, request),
                            child: const Text('Aceptar'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await requestService.reject(request);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Solicitud rechazada'),
                                ),
                              );
                            },
                            child: const Text('Rechazar'),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  String _requestStatusLabel(OperatorRequestStatus status) {
    switch (status) {
      case OperatorRequestStatus.approved:
        return 'Aprobada';
      case OperatorRequestStatus.rejected:
        return 'Rechazada';
      case OperatorRequestStatus.pending:
        return 'Pendiente';
    }
  }

  Future<void> _approveRequest(
    BuildContext context,
    OperatorRequest request,
  ) async {
    final pinController = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear PIN de operador'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = pinController.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    pinController.dispose();
    if (pin == null) return;

    await requestService.approve(request, pin);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operador aprobado y PIN asignado')),
    );
  }
}

Widget _adminField(
  TextEditingController c,
  String label, {
  TextInputType type = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo requerido';
        if (type == TextInputType.number && int.tryParse(v.trim()) == null) {
          return 'Número válido';
        }
        return null;
      },
    ),
  );
}

// ── Panel de Métricas ─────────────────────────────────────────────────────
class _MetricsDashboard extends StatelessWidget {
  const _MetricsDashboard({
    required this.totalUsers,
    required this.totalListings,
    required this.activeListings,
    required this.pendingListings,
  });

  final int totalUsers;
  final int totalListings;
  final int activeListings;
  final int pendingListings;

  @override
  Widget build(BuildContext context) {
    const kEmerald = Color(0xFF1B4332);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Control',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                label: 'Usuarios registrados',
                value: '$totalUsers',
                icon: Icons.people,
                color: kEmerald,
              ),
              _MetricCard(
                label: 'Ofertas totales',
                value: '$totalListings',
                icon: Icons.home_work,
                color: const Color(0xFF2D6A4F),
              ),
              _MetricCard(
                label: 'Ofertas activas',
                value: '$activeListings',
                icon: Icons.visibility,
                color: const Color(0xFF52B788),
              ),
              _MetricCard(
                label: 'Pendientes aprobación',
                value: '$pendingListings',
                icon: Icons.pending_actions,
                color: const Color(0xFFD4A853),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Actividad reciente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.person_add_outlined,
            text: 'Nuevo usuario registrado',
            time: 'Hace 5 min',
          ),
          _ActivityItem(
            icon: Icons.add_home_work_outlined,
            text: 'Nueva oferta enviada para aprobación',
            time: 'Hace 12 min',
          ),
          _ActivityItem(
            icon: Icons.rate_review_outlined,
            text: 'Nueva reseña publicada',
            time: 'Hace 1 hora',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.text,
    required this.time,
  });

  final IconData icon;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF1B4332)),
      title: Text(text),
      trailing: Text(time, style: const TextStyle(color: Colors.black38)),
    );
  }
}

// ── Gestión de Usuarios ───────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.users, required this.onUpdateUser});

  final List<AppUser> users;
  final ValueChanged<AppUser> onUpdateUser;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('No hay usuarios'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final user = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1B4332).withValues(alpha: 0.12),
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF1B4332),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(user.name),
            subtitle: Text('${user.email} · ${_roleLabel(user.role)}'),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleUserAction(context, user, action),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'traveler',
                  child: Text('Asignar como Viajero'),
                ),
                const PopupMenuItem(
                  value: 'operator',
                  child: Text('Asignar como Operador'),
                ),
                const PopupMenuItem(
                  value: 'admin',
                  child: Text('Asignar como Admin'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'suspend',
                  child: Text('Suspender / Activar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.operator:
        return 'Operador';
      case UserRole.traveler:
        return 'Viajero';
      default:
        return 'Invitado';
    }
  }

  void _handleUserAction(BuildContext context, AppUser user, String action) {
    UserRole? newRole;
    switch (action) {
      case 'traveler':
        newRole = UserRole.traveler;
        break;
      case 'operator':
        newRole = UserRole.operator;
        break;
      case 'admin':
        newRole = UserRole.admin;
        break;
    }
    if (newRole != null) {
      onUpdateUser(user.copyWith(role: newRole));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol de ${user.firstName} actualizado')),
      );
    }
  }
}

// ── Gestión de Ofertas (Admin) ────────────────────────────────────────────
class _ListingsAdminTab extends StatelessWidget {
  const _ListingsAdminTab({
    required this.listings,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AlojaListing> listings;
  final ValueChanged<AlojaListing> onApprove;
  final ValueChanged<AlojaListing> onReject;
  final ValueChanged<AlojaListing> onEdit;
  final ValueChanged<AlojaListing> onDelete;

  @override
  Widget build(BuildContext context) {
    // Mostrar pendientes primero
    final sorted = [...listings]
      ..sort((a, b) {
        if (a.status == ListingStatus.pendingApproval) return -1;
        if (b.status == ListingStatus.pendingApproval) return 1;
        return 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final l = sorted[i];
        final isPending = l.status == ListingStatus.pendingApproval;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: isPending ? const Color(0xFFFFFDE7) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isPending)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PENDIENTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        l.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text('${l.city} · ${l.priceLabel}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (isPending) ...[
                      FilledButton.icon(
                        onPressed: () => onApprove(l),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Aprobar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onReject(l),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => onEdit(l),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onDelete(l),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Mantenimiento (tablas del sistema) ────────────────────────────────────
class _MaintenanceTab extends StatefulWidget {
  const _MaintenanceTab();

  @override
  State<_MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<_MaintenanceTab> {
  final List<String> _types = [
    'Hotel',
    'Posada',
    'Cabaña',
    'Apartamento',
    'Resort',
  ];
  final List<String> _categories = ['Estándar', 'Premium', 'Económico', 'Lujo'];

  void _addItem(List<String> list, String label) async {
    final c = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar $label'),
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) {
                Navigator.pop(context, c.text.trim());
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    c.dispose();
    if (result != null) setState(() => list.add(result));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tablas de Mantenimiento',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _TableSection(
            title: 'Tipos de Hospedaje',
            items: _types,
            onAdd: () => _addItem(_types, 'Tipo'),
            onDelete: (item) => setState(() => _types.remove(item)),
          ),
          const SizedBox(height: 20),
          _TableSection(
            title: 'Categorías de Reserva',
            items: _categories,
            onAdd: () => _addItem(_categories, 'Categoría'),
            onDelete: (item) => setState(() => _categories.remove(item)),
          ),
        ],
      ),
    );
  }
}

class _TableSection extends StatelessWidget {
  const _TableSection({
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onDelete,
  });

  final String title;
  final List<String> items;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Agregar',
                ),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDelete(item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gestión de PINs (solo admin) ──────────────────────────────────────────
class _PinManagementTab extends StatefulWidget {
  const _PinManagementTab({required this.pinService});
  final PinService pinService;

  @override
  State<_PinManagementTab> createState() => _PinManagementTabState();
}

class _PinManagementTabState extends State<_PinManagementTab> {
  final _operatorPinC = TextEditingController();
  final _adminPinC = TextEditingController();
  bool _loading = false;
  bool _saved = false;
  bool _showOperator = false;
  bool _showAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    setState(() => _loading = true);
    final opPin = await widget.pinService.getPin(isAdmin: false);
    final admPin = await widget.pinService.getPin(isAdmin: true);
    if (mounted) {
      _operatorPinC.text = opPin;
      _adminPinC.text = admPin;
      setState(() => _loading = false);
    }
  }

  Future<void> _savePins() async {
    final opPin = _operatorPinC.text.trim();
    final admPin = _adminPinC.text.trim();
    if (opPin.isEmpty || admPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los PINs no pueden estar vacíos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (opPin == admPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los PINs deben ser distintos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await widget.pinService.updatePin(
      newOperatorPin: opPin,
      newAdminPin: admPin,
    );
    setState(() {
      _loading = false;
      _saved = true;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PINs actualizados correctamente'),
        backgroundColor: Color(0xFF1B4332),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  void dispose() {
    _operatorPinC.dispose();
    _adminPinC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de PINs',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solo el administrador puede modificar estos PINs.\n'
            'Los PINs son requeridos al registrarse como Operador o Administrador.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _PinField(
              label: 'PIN de Operador Turístico',
              controller: _operatorPinC,
              obscure: !_showOperator,
              onToggle: () => setState(() => _showOperator = !_showOperator),
              color: const Color(0xFFD4A853),
            ),
            const SizedBox(height: 16),
            _PinField(
              label: 'PIN de Administrador',
              controller: _adminPinC,
              obscure: !_showAdmin,
              onToggle: () => setState(() => _showAdmin = !_showAdmin),
              color: const Color(0xFFBF6B3D),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _savePins,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'PINs guardados' : 'Guardar PINs'),
                style: FilledButton.styleFrom(
                  backgroundColor: _saved
                      ? Colors.green
                      : const Color(0xFF1B4332),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.color,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.pin_outlined, color: color),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
