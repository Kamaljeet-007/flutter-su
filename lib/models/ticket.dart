import 'package:flutter/foundation.dart';

enum TicketPriority { low, medium, high, critical }
enum TicketStatus { open, inProgress, resolved, closed }
enum TicketCategory { 
  technical, 
  billing, 
  feature, 
  bug, 
  security, 
  other 
}

class Ticket {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final List<TicketComment> comments;
  final List<String> attachments;

  Ticket({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.comments = const [],
    this.attachments = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: TicketCategory.values.byName(json['category']),
      priority: TicketPriority.values.byName(json['priority']),
      status: TicketStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      comments: (json['comments'] as List?)
          ?.map((e) => TicketComment.fromJson(e))
          .toList() ?? [],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'attachments': attachments,
    };
  }
}

class TicketComment {
  final String id;
  final String ticketId;
  final String userId;
  final String comment;
  final bool isAdminComment;
  final DateTime createdAt;

  TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.comment,
    required this.isAdminComment,
    required this.createdAt,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'],
      ticketId: json['ticket_id'],
      userId: json['user_id'],
      comment: json['comment'],
      isAdminComment: json['is_admin_comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'comment': comment,
      'is_admin_comment': isAdminComment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}