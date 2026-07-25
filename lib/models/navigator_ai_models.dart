import 'package:equatable/equatable.dart';

class NavigatorAiConversation extends Equatable {
  const NavigatorAiConversation({
    this.id = '',
    this.title = 'New Chat',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NavigatorAiConversation.fromJson(Map<String, dynamic> json) {
    return NavigatorAiConversation(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'New Chat').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  NavigatorAiConversation copyWith({String? id, String? title}) {
    return NavigatorAiConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}

class NavigatorAiMessage extends Equatable {
  const NavigatorAiMessage({
    required this.role,
    required this.content,
    this.timestamp,
    this.followUps = const [],
    this.visualizations = const [],
  });

  final String role; // user | assistant
  final String content;
  final DateTime? timestamp;
  final List<String> followUps;
  final List<Map<String, dynamic>> visualizations;

  factory NavigatorAiMessage.fromJson(Map<String, dynamic> json) {
    final followUps = json['follow_ups'] ?? json['follow_up_prompts'];
    final viz = json['visualizations'] ?? json['visualization'];
    return NavigatorAiMessage(
      role: (json['role'] ?? 'assistant').toString(),
      content: (json['content'] ?? json['answer'] ?? json['message'] ?? '')
          .toString(),
      timestamp: DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      followUps: followUps is List
          ? followUps.map((e) => e.toString()).toList()
          : const [],
      visualizations: viz is List
          ? viz
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props =>
      [role, content, timestamp, followUps, visualizations];
}

class DailyBriefing extends Equatable {
  const DailyBriefing({
    this.date = '',
    this.revenue,
    this.capacity,
    this.cash,
    this.creditNotes,
  });

  final String date;
  final BriefingRevenue? revenue;
  final BriefingCapacity? capacity;
  final BriefingCash? cash;
  final BriefingCreditNotes? creditNotes;

  int get areaCount =>
      [revenue, capacity, cash, creditNotes].where((e) => e != null).length;

  factory DailyBriefing.fromJson(Map<String, dynamic> json) {
    return DailyBriefing(
      date: (json['date'] ?? '').toString(),
      revenue: json['revenue'] is Map
          ? BriefingRevenue.fromJson(Map<String, dynamic>.from(json['revenue']))
          : null,
      capacity: json['capacity'] is Map
          ? BriefingCapacity.fromJson(
              Map<String, dynamic>.from(json['capacity']),
            )
          : null,
      cash: json['cash'] is Map
          ? BriefingCash.fromJson(Map<String, dynamic>.from(json['cash']))
          : null,
      creditNotes: json['credit_notes'] is Map
          ? BriefingCreditNotes.fromJson(
              Map<String, dynamic>.from(json['credit_notes']),
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [date, revenue, capacity, cash, creditNotes];
}

class BriefingRevenue extends Equatable {
  const BriefingRevenue({
    this.yesterday = 0,
    this.yesterdayPct,
    this.mtd = 0,
    this.mtdPct,
    this.summary = '',
  });

  final double yesterday;
  final double? yesterdayPct;
  final double mtd;
  final double? mtdPct;
  final String summary;

  factory BriefingRevenue.fromJson(Map<String, dynamic> json) {
    return BriefingRevenue(
      yesterday: _d(json['yesterday']),
      yesterdayPct: _dn(json['yesterday_pct']),
      mtd: _d(json['mtd']),
      mtdPct: _dn(json['mtd_pct']),
      summary: (json['summary'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [yesterday, yesterdayPct, mtd, mtdPct, summary];
}

class BriefingCapacity extends Equatable {
  const BriefingCapacity({
    this.completed = 0,
    this.total = 0,
    this.completionRate = 0,
    this.today = 0,
    this.tomorrow = 0,
    this.summary = '',
  });

  final int completed;
  final int total;
  final double completionRate;
  final int today;
  final int tomorrow;
  final String summary;

  factory BriefingCapacity.fromJson(Map<String, dynamic> json) {
    return BriefingCapacity(
      completed: _i(json['completed']),
      total: _i(json['total']),
      completionRate: _d(json['completion_rate']),
      today: _i(json['today']),
      tomorrow: _i(json['tomorrow']),
      summary: (json['summary'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props =>
      [completed, total, completionRate, today, tomorrow, summary];
}

class BriefingCash extends Equatable {
  const BriefingCash({
    this.collectedYesterday = 0,
    this.outstanding = 0,
    this.overdue30d = 0,
    this.summary = '',
  });

  final double collectedYesterday;
  final double outstanding;
  final double overdue30d;
  final String summary;

  factory BriefingCash.fromJson(Map<String, dynamic> json) {
    return BriefingCash(
      collectedYesterday: _d(json['collected_yesterday']),
      outstanding: _d(json['outstanding']),
      overdue30d: _d(json['overdue_30d']),
      summary: (json['summary'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props =>
      [collectedYesterday, outstanding, overdue30d, summary];
}

class BriefingCreditNotes extends Equatable {
  const BriefingCreditNotes({
    this.mtd = 0,
    this.mtdPct,
    this.topTrade,
    this.topTradeAmount = 0,
    this.topTradePct,
    this.summary = '',
  });

  final double mtd;
  final double? mtdPct;
  final String? topTrade;
  final double topTradeAmount;
  final double? topTradePct;
  final String summary;

  factory BriefingCreditNotes.fromJson(Map<String, dynamic> json) {
    return BriefingCreditNotes(
      mtd: _d(json['mtd']),
      mtdPct: _dn(json['mtd_pct']),
      topTrade: json['top_trade']?.toString(),
      topTradeAmount: _d(json['top_trade_amount']),
      topTradePct: _dn(json['top_trade_pct']),
      summary: (json['summary'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props =>
      [mtd, mtdPct, topTrade, topTradeAmount, topTradePct, summary];
}

double _d(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

double? _dn(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _i(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
