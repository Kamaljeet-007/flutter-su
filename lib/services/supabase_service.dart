import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_system/models/ticket.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Ticket>> getTickets({bool isAdmin = false}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final query = supabase
        .from('tickets')
        .select('''
          *,
          profiles:user_id(email),
          ticket_comments:ticket_comments(
            id,
            comment,
            is_admin_comment,
            created_at,
            profiles:user_id(email)
          )
        ''')
        .order('created_at', ascending: false);

    final data = await query;
    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  Future<Ticket> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    List<String> attachments = const [],
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final data = await supabase
        .from('tickets')
        .insert({
          'user_id': user.id,
          'title': title,
          'description': description,
          'category': category.name,
          'priority': priority.name,
          'status': TicketStatus.open.name,
          'attachments': attachments,
        })
        .select('''
          *,
          profiles:user_id(email),
          ticket_comments:ticket_comments(
            id,
            comment,
            is_admin_comment,
            created_at,
            profiles:user_id(email)
          )
        ''')
        .single();

    return Ticket.fromJson(data);
  }

  Future<void> addComment({
    required String ticketId,
    required String comment,
    required bool isAdminComment,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await supabase.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'user_id': user.id,
      'comment': comment,
      'is_admin_comment': isAdminComment,
    });
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    await supabase
        .from('tickets')
        .update({'status': status.name})
        .eq('id', ticketId);
  }

  Stream<List<Ticket>> streamTickets({bool isAdmin = false}) {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return supabase
        .from('tickets')
        .stream(primaryKey: ['id'])
        .eq(isAdmin ? null : 'user_id', isAdmin ? null : user.id)
        .map((data) => data.map((json) => Ticket.fromJson(json)).toList());
  }

  Future<String> uploadAttachment(String fileName, List<int> fileBytes) async {
    final path = 'attachments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await supabase.storage.from('ticket-attachments').uploadBinary(path, fileBytes);
    return path;
  }

  Future<String> getAttachmentUrl(String path) async {
    return supabase.storage.from('ticket-attachments').getPublicUrl(path);
  }
}