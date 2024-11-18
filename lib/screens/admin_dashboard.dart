import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_system/models/ticket.dart';
import 'package:ticket_system/services/supabase_service.dart';
import 'package:ticket_system/widgets/admin_ticket_list.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _supabaseService = SupabaseService();
  TicketStatus? _statusFilter;
  TicketPriority? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<TicketStatus>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() => _statusFilter = status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              ...TicketStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(status.name),
              )),
            ],
          ),
          PopupMenuButton<TicketPriority>(
            icon: const Icon(Icons.priority_high),
            onSelected: (priority) {
              setState(() => _priorityFilter = priority);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Priorities'),
              ),
              ...TicketPriority.values.map((priority) => PopupMenuItem(
                value: priority,
                child: Text(priority.name),
              )),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: _supabaseService.streamTickets(isAdmin: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var tickets = snapshot.data!;
          
          if (_statusFilter != null) {
            tickets = tickets.where((t) => t.status == _statusFilter).toList();
          }
          
          if (_priorityFilter != null) {
            tickets = tickets.where((t) => t.priority == _priorityFilter).toList();
          }

          return AdminTicketList(tickets: tickets);
        },
      ),
    );
  }
}