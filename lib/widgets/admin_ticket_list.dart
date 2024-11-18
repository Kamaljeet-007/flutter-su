import 'package:flutter/material.dart';
import 'package:ticket_system/models/ticket.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminTicketList extends StatelessWidget {
  final List<Ticket> tickets;

  const AdminTicketList({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Text(ticket.title),
            subtitle: Text(
              'User ID: ${ticket.userId} • ${timeago.format(ticket.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: _getPriorityIcon(ticket.priority),
            trailing: _getStatusChip(ticket.status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.description),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: TicketStatus.values.map((status) {
                        return FilterChip(
                          label: Text(status.name),
                          selected: ticket.status == status,
                          onSelected: (selected) {
                            // Update ticket status
                          },
                        );
                      }).toList(),
                    ),
                    if (ticket.attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Attachments:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        spacing: 8,
                        children: ticket.attachments.map((url) {
                          return Chip(
                            label: Text(url.split('/').last),
                            onDeleted: () {
                              // Handle attachment download
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Add admin comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onSubmitted: (comment) {
                        // Add admin comment
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getPriorityIcon(TicketPriority priority) {
    IconData icon;
    Color color;
    
    switch (priority) {
      case TicketPriority.low:
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      case TicketPriority.medium:
        icon = Icons.remove;
        color = Colors.orange;
        break;
      case TicketPriority.high:
        icon = Icons.arrow_upward;
        color = Colors.red;
        break;
      case TicketPriority.critical:
        icon = Icons.warning;
        color = Colors.red;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _getStatusChip(TicketStatus status) {
    Color color;
    
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.name,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}