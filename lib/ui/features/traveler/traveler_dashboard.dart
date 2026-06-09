// lib/ui/features/traveler/traveler_dashboard.dart
// Panel del Viajero: Mis Reservas, búsqueda de ofertas, reseñas.

import 'package:flutter/material.dart';

import '../../../domain/models/app_user.dart';
import '../../../domain/models/listing.dart';

// Modelo simple de reserva local
class TravelerReservation {
  const TravelerReservation({
    required this.id,
    required this.listing,
    required this.nights,
    required this.total,
    required this.createdAt,
    this.status = ReservationStatus.confirmed,
  });

  final String id;
  final AlojaListing listing;
  final int nights;
  final int total;
  final DateTime createdAt;
  final ReservationStatus status;

  TravelerReservation copyWith({ReservationStatus? status}) {
    return TravelerReservation(
      id: id,
      listing: listing,
      nights: nights,
      total: total,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

enum ReservationStatus { confirmed, cancelled, completed }

class TravelerDashboard extends StatefulWidget {
  const TravelerDashboard({
    super.key,
    required this.user,
    required this.listings,
    required this.onReserve,
    required this.onReview,
  });

  final AppUser user;
  final List<AlojaListing> listings;
  final Future<bool> Function(AlojaListing listing, int nights) onReserve;
  final void Function(AlojaListing listing) onReview;

  @override
  State<TravelerDashboard> createState() => _TravelerDashboardState();
}

class _TravelerDashboardState extends State<TravelerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TravelerReservation> _myReservations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cancelReservation(TravelerReservation res) {
    setState(() {
      final idx = _myReservations.indexWhere((r) => r.id == res.id);
      if (idx != -1) {
        _myReservations[idx] =
            res.copyWith(status: ReservationStatus.cancelled);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva cancelada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${widget.user.firstName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Explorar'),
            Tab(icon: Icon(Icons.bookmark_outlined), text: 'Mis Reservas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExploreTab(
            listings: widget.listings,
            onReserve: (listing, nights) async {
              final ok = await widget.onReserve(listing, nights);
              if (ok) {
                setState(() {
                  _myReservations.add(
                    TravelerReservation(
                      id: 'res-${DateTime.now().microsecondsSinceEpoch}',
                      listing: listing,
                      nights: nights,
                      total: listing.nightlyPrice * nights,
                      createdAt: DateTime.now(),
                    ),
                  );
                  _tabController.animateTo(1);
                });
              }
            },
            onReview: widget.onReview,
          ),
          _MyReservationsTab(
            reservations: _myReservations,
            onCancel: _cancelReservation,
            onReview: (res) => widget.onReview(res.listing),
          ),
        ],
      ),
    );
  }
}

// ── Tab Explorar ─────────────────────────────────────────────────────────
class _ExploreTab extends StatefulWidget {
  const _ExploreTab({
    required this.listings,
    required this.onReserve,
    required this.onReview,
  });

  final List<AlojaListing> listings;
  final Future<void> Function(AlojaListing listing, int nights) onReserve;
  final void Function(AlojaListing listing) onReview;

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  final _searchController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _guestsController = TextEditingController();
  String _typeFilter = 'Todos';

  List<AlojaListing> get _filtered {
    final maxPrice = int.tryParse(_maxPriceController.text);
    final guests = int.tryParse(_guestsController.text);
    return widget.listings.where((l) {
      final matchSearch = l.matchesSearch(
        destination: _searchController.text,
        maxPrice: maxPrice,
        guests: guests,
      );
      final matchType =
          _typeFilter == 'Todos' ||
          l.accommodationType == _typeFilter ||
          l.category == _typeFilter;
      return matchSearch && matchType;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _maxPriceController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio máx.',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _guestsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Huéspedes',
                        prefixIcon: Icon(Icons.group_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Hotel', 'Posada', 'Cabaña', 'Apartamento']
                      .map(
                        (type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(type),
                            selected: _typeFilter == type,
                            onSelected: (_) =>
                                setState(() => _typeFilter = type),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No se encontraron resultados'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final l = filtered[index];
                    return _ListingTile(
                      listing: l,
                      onReserve: () async {
                        final nights = await _showNightsDialog(context);
                        if (nights == null) return;
                        await widget.onReserve(l, nights);
                      },
                      onReview: () => widget.onReview(l),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<int?> _showNightsDialog(BuildContext context) async {
    final controller = TextEditingController(text: '2');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cuántas noches?'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Noches',
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
              final n = int.tryParse(controller.text);
              if (n != null && n > 0) Navigator.pop(context, n);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({
    required this.listing,
    required this.onReserve,
    required this.onReview,
  });

  final AlojaListing listing;
  final VoidCallback onReserve;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            listing.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(
          listing.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${listing.city} · ${listing.priceLabel} · ⭐ ${listing.rating.toStringAsFixed(1)}',
        ),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: onReview,
              icon: const Icon(Icons.rate_review_outlined),
              tooltip: 'Reseña',
            ),
            FilledButton.icon(
              onPressed: listing.hasAvailability ? onReserve : null,
              icon: const Icon(Icons.credit_card, size: 16),
              label: Text(
                listing.hasAvailability ? 'Reservar' : 'Agotado',
              ),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Mis Reservas ──────────────────────────────────────────────────────
class _MyReservationsTab extends StatelessWidget {
  const _MyReservationsTab({
    required this.reservations,
    required this.onCancel,
    required this.onReview,
  });

  final List<TravelerReservation> reservations;
  final void Function(TravelerReservation) onCancel;
  final void Function(TravelerReservation) onReview;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'Aún no tienes reservas',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
        final statusColor = switch (res.status) {
          ReservationStatus.confirmed => Colors.green,
          ReservationStatus.cancelled => Colors.red,
          ReservationStatus.completed => Colors.blue,
        };
        final statusLabel = switch (res.status) {
          ReservationStatus.confirmed => 'Confirmada',
          ReservationStatus.cancelled => 'Cancelada',
          ReservationStatus.completed => 'Completada',
        };

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        res.listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${res.listing.city} · ${res.nights} noches · \$${res.total}',
                ),
                Text(
                  'Creada: ${res.createdAt.day}/${res.createdAt.month}/${res.createdAt.year}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                if (res.status == ReservationStatus.confirmed) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onCancel(res),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => onReview(res),
                        icon: const Icon(Icons.star_outline, size: 16),
                        label: const Text('Reseñar'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
