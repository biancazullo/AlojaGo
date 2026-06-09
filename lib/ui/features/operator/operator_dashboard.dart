// lib/ui/features/operator/operator_dashboard.dart
// Panel del Operador Turístico: publicar/editar/eliminar ofertas,
// gestionar solicitudes de reserva, historial, responder reseñas.

import 'package:flutter/material.dart';

import '../../../domain/models/app_user.dart';
import '../../../domain/models/listing.dart';

// Modelo de solicitud de reserva recibida por el operador
class ReservationRequest {
  const ReservationRequest({
    required this.id,
    required this.listing,
    required this.travelerName,
    required this.nights,
    required this.total,
    required this.requestedAt,
    this.status = RequestStatus.pending,
  });

  final String id;
  final AlojaListing listing;
  final String travelerName;
  final int nights;
  final int total;
  final DateTime requestedAt;
  final RequestStatus status;

  ReservationRequest copyWith({RequestStatus? status}) {
    return ReservationRequest(
      id: id,
      listing: listing,
      travelerName: travelerName,
      nights: nights,
      total: total,
      requestedAt: requestedAt,
      status: status ?? this.status,
    );
  }
}

enum RequestStatus { pending, accepted, rejected }

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({
    super.key,
    required this.user,
    required this.allListings,
    required this.onSaveListing,
    required this.onDeleteListing,
    required this.onToggleStatus,
  });

  final AppUser user;
  final List<AlojaListing> allListings;
  final void Function(AlojaListing listing) onSaveListing;
  final void Function(AlojaListing listing) onDeleteListing;
  final void Function(AlojaListing listing) onToggleStatus;

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Solicitudes simuladas de reserva
  final List<ReservationRequest> _requests = [
    ReservationRequest(
      id: 'req-1',
      listing: AlojaListing(
        id: 'placeholder',
        ownerId: '',
        title: 'Ejemplo de reserva',
        city: 'Caracas',
        region: 'DC',
        nightlyPrice: 45,
        maxGuests: 2,
        imageUrl: '',
        tag: 'Demo',
        rating: 4.5,
        reviews: const [],
      ),
      travelerName: 'María González',
      nights: 3,
      total: 135,
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<AlojaListing> get _myListings =>
      widget.allListings.where((l) => l.ownerId == widget.user.id).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptRequest(ReservationRequest req) {
    setState(() {
      final idx = _requests.indexWhere((r) => r.id == req.id);
      if (idx != -1) _requests[idx] = req.copyWith(status: RequestStatus.accepted);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva aceptada')),
    );
  }

  void _rejectRequest(ReservationRequest req) {
    setState(() {
      final idx = _requests.indexWhere((r) => r.id == req.id);
      if (idx != -1) _requests[idx] = req.copyWith(status: RequestStatus.rejected);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva rechazada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operador · ${widget.user.firstName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home_work_outlined), text: 'Mis Ofertas'),
            Tab(icon: Icon(Icons.inbox_outlined), text: 'Solicitudes'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyListingsTab(
            listings: _myListings,
            onAdd: () => _openListingForm(context),
            onEdit: (l) => _openListingForm(context, listing: l),
            onDelete: widget.onDeleteListing,
            onToggleStatus: widget.onToggleStatus,
          ),
          _RequestsTab(
            requests: _requests,
            onAccept: _acceptRequest,
            onReject: _rejectRequest,
          ),
          _HistoryTab(
            requests: _requests
                .where((r) => r.status != RequestStatus.pending)
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _openListingForm(
    BuildContext context, {
    AlojaListing? listing,
  }) async {
    final titleC = TextEditingController(text: listing?.title ?? '');
    final cityC = TextEditingController(text: listing?.city ?? '');
    final regionC = TextEditingController(text: listing?.region ?? '');
    final priceC = TextEditingController(
      text: listing?.nightlyPrice.toString() ?? '',
    );
    final guestsC = TextEditingController(
      text: listing?.maxGuests.toString() ?? '',
    );
    final imageC = TextEditingController(text: listing?.imageUrl ?? '');
    final maxResC = TextEditingController(
      text: listing?.maxReservations.toString() ?? '0',
    );
    String typeValue = listing?.accommodationType ?? 'Hotel';
    String catValue = listing?.category ?? 'Estándar';
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<AlojaListing>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setS) {
            return AlertDialog(
              title: Text(listing == null ? 'Nueva oferta' : 'Editar oferta'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _opField(titleC, 'Título'),
                        _opField(cityC, 'Ciudad'),
                        _opField(regionC, 'Región'),
                        _opField(
                          priceC,
                          'Precio por noche',
                          type: TextInputType.number,
                        ),
                        _opField(
                          guestsC,
                          'Huéspedes máximos',
                          type: TextInputType.number,
                        ),
                        _opField(
                          maxResC,
                          'Cantidad máx. de reservas (0 = sin límite)',
                          type: TextInputType.number,
                        ),
                        _opField(imageC, 'URL de imagen', required: false),
                        // Tipo de alojamiento
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: typeValue,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de alojamiento',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Hotel', 'Posada', 'Cabaña', 'Apartamento', 'Resort']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setS(() => typeValue = v ?? typeValue),
                          ),
                        ),
                        // Categoría
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            value: catValue,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Estándar', 'Premium', 'Económico', 'Lujo']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setS(() => catValue = v ?? catValue),
                          ),
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
                    final saved = AlojaListing(
                      id: listing?.id ??
                          'listing-${DateTime.now().microsecondsSinceEpoch}',
                      ownerId: widget.user.id,
                      title: titleC.text.trim(),
                      city: cityC.text.trim(),
                      region: regionC.text.trim(),
                      nightlyPrice: int.parse(priceC.text.trim()),
                      maxGuests: int.parse(guestsC.text.trim()),
                      imageUrl: imageC.text.trim().isEmpty
                          ? 'https://via.placeholder.com/400x250'
                          : imageC.text.trim(),
                      tag: listing?.tag ?? 'Operador',
                      rating: listing?.rating ?? 0,
                      reviews: listing?.reviews ?? const [],
                      status: listing?.status ?? ListingStatus.pendingApproval,
                      maxReservations: int.tryParse(maxResC.text.trim()) ?? 0,
                      currentReservations: listing?.currentReservations ?? 0,
                      accommodationType: typeValue,
                      category: catValue,
                    );
                    Navigator.pop(context, saved);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    for (final c in [titleC, cityC, regionC, priceC, guestsC, imageC, maxResC]) {
      c.dispose();
    }

    if (saved == null) return;
    widget.onSaveListing(saved);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(listing == null
              ? 'Oferta enviada para aprobación'
              : 'Oferta actualizada'),
        ),
      );
    }
  }
}

Widget _opField(
  TextEditingController c,
  String label, {
  TextInputType type = TextInputType.text,
  bool required = true,
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
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (type == TextInputType.number &&
                  int.tryParse(v.trim()) == null) return 'Número válido';
              return null;
            }
          : null,
    ),
  );
}

// ── Sub-tabs ────────────────────────────────────────────────────────────
class _MyListingsTab extends StatelessWidget {
  const _MyListingsTab({
    required this.listings,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final List<AlojaListing> listings;
  final VoidCallback onAdd;
  final ValueChanged<AlojaListing> onEdit;
  final ValueChanged<AlojaListing> onDelete;
  final ValueChanged<AlojaListing> onToggleStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Mis publicaciones',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Nueva oferta'),
              ),
            ],
          ),
        ),
        Expanded(
          child: listings.isEmpty
              ? const Center(
                  child: Text('Aún no tienes ofertas publicadas'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final l = listings[i];
                    final statusLabel = switch (l.status) {
                      ListingStatus.active => 'Activa',
                      ListingStatus.paused => 'Pausada',
                      ListingStatus.pendingApproval => 'Pendiente aprobación',
                      ListingStatus.rejected => 'Rechazada',
                    };
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          l.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$statusLabel · ${l.priceLabel} · '
                          '${l.maxReservations == 0 ? "Sin límite" : "${l.currentReservations}/${l.maxReservations} reservas"}',
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: () => onEdit(l),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              onPressed: () => onToggleStatus(l),
                              icon: Icon(
                                l.status == ListingStatus.active
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                              ),
                              tooltip: 'Pausar/Activar',
                            ),
                            IconButton(
                              onPressed: () => onDelete(l),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.requests,
    required this.onAccept,
    required this.onReject,
  });

  final List<ReservationRequest> requests;
  final ValueChanged<ReservationRequest> onAccept;
  final ValueChanged<ReservationRequest> onReject;

  @override
  Widget build(BuildContext context) {
    final pending = requests.where((r) => r.status == RequestStatus.pending).toList();
    if (pending.isEmpty) {
      return const Center(child: Text('No hay solicitudes pendientes'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final req = pending[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.listing.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Viajero: ${req.travelerName}'),
                Text('${req.nights} noches · Total: \$${req.total}'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => onAccept(req),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aceptar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onReject(req),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rechazar'),
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

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.requests});
  final List<ReservationRequest> requests;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text('Sin historial aún'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final req = requests[i];
        final isAccepted = req.status == RequestStatus.accepted;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              isAccepted ? Icons.check_circle : Icons.cancel,
              color: isAccepted ? Colors.green : Colors.red,
            ),
            title: Text(req.listing.title),
            subtitle: Text(
              '${req.travelerName} · ${req.nights} noches · \$${req.total}',
            ),
            trailing: Text(
              isAccepted ? 'Aceptada' : 'Rechazada',
              style: TextStyle(
                color: isAccepted ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
