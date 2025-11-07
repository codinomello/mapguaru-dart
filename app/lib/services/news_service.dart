import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Serviço para buscar e gerenciar notícias de Guarulhos
class NewsService {
  // APIs possíveis para integração
  static const String _guarulhosGovUrl = 'https://www.guarulhos.sp.gov.br';
  static const String _rssUrl = '$_guarulhosGovUrl/feed';
  
  /// Busca notícias da prefeitura
  static Future<List<NewsItem>> fetchNews({
    NewsCategory? category,
    int limit = 20,
  }) async {
    try {
      debugPrint('📰 Buscando notícias...');
      
      // Tenta buscar do RSS da prefeitura
      final response = await http.get(
        Uri.parse(_rssUrl),
        headers: {'Accept': 'application/xml, application/rss+xml'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return _parseRSSFeed(response.body, limit);
      } else {
        debugPrint('⚠️ Erro ao buscar notícias: ${response.statusCode}');
        return _getFallbackNews();
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar notícias: $e');
      return _getFallbackNews();
    }
  }

  /// Parse do feed RSS
  static List<NewsItem> _parseRSSFeed(String xml, int limit) {
    final news = <NewsItem>[];
    
    try {
      // Parse simples de XML/RSS
      final itemPattern = RegExp(
        r'<item>(.*?)</item>',
        dotAll: true,
        multiLine: true,
      );
      final items = itemPattern.allMatches(xml);
      
      for (var match in items) {
        final item = match.group(1) ?? '';
        
        final title = _extractTag(item, 'title');
        final description = _extractTag(item, 'description');
        final link = _extractTag(item, 'link');
        final pubDate = _extractTag(item, 'pubDate');
        final category = _extractTag(item, 'category');
        
        if (title != null) {
          news.add(NewsItem(
            title: _cleanHtml(title),
            description: _cleanHtml(description ?? ''),
            imageUrl: _extractImageFromDescription(description),
            link: link,
            publishedAt: _parseDate(pubDate),
            category: _mapCategory(category),
          ));
        }
        
        if (news.length >= limit) break;
      }
      
      debugPrint('✅ ${news.length} notícias carregadas');
    } catch (e) {
      debugPrint('⚠️ Erro ao fazer parse do RSS: $e');
    }
    
    return news.isEmpty ? _getFallbackNews() : news;
  }

  /// Extrai tag XML
  static String? _extractTag(String xml, String tag) {
    final pattern = RegExp('<$tag[^>]*>(.*?)</$tag>', dotAll: true);
    final match = pattern.firstMatch(xml);
    return match?.group(1)?.trim();
  }

  /// Remove HTML tags
  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8211;', '-')
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .trim();
  }

  /// Extrai URL de imagem da descrição
  static String? _extractImageFromDescription(String? description) {
    if (description == null) return null;
    
    final imgPattern = RegExp(r'<img[^>]+src="([^"]+)"');
    final match = imgPattern.firstMatch(description);
    return match?.group(1);
  }

  /// Parse de data
  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    
    try {
      // Tenta diferentes formatos
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateStr);
    } catch (e) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  /// Mapeia categoria do RSS para categoria do app
  static NewsCategory _mapCategory(String? category) {
    if (category == null) return NewsCategory.general;
    
    final lower = category.toLowerCase();
    
    if (lower.contains('saúde') || lower.contains('saude')) {
      return NewsCategory.health;
    } else if (lower.contains('educação') || lower.contains('educacao')) {
      return NewsCategory.education;
    } else if (lower.contains('obra') || lower.contains('construção')) {
      return NewsCategory.infrastructure;
    } else if (lower.contains('evento') || lower.contains('cultura')) {
      return NewsCategory.events;
    } else if (lower.contains('segurança') || lower.contains('seguranca')) {
      return NewsCategory.security;
    } else if (lower.contains('transporte') || lower.contains('trânsito')) {
      return NewsCategory.transport;
    }
    
    return NewsCategory.general;
  }

  /// Notícias de fallback (quando a API falha)
  static List<NewsItem> _getFallbackNews() {
    return [
      NewsItem(
        title: 'Prefeitura amplia horário de atendimento em UBS',
        description: 'Unidades Básicas de Saúde terão funcionamento estendido para melhor atender a população de Guarulhos.',
        imageUrl: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        category: NewsCategory.health,
      ),
      NewsItem(
        title: 'Nova linha de ônibus conecta Bonsucesso ao Centro',
        description: 'Medida visa facilitar o deslocamento dos moradores e trabalhadores da região.',
        imageUrl: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        category: NewsCategory.transport,
      ),
      NewsItem(
        title: 'Início das obras de revitalização da Av. Paulo Faccini',
        description: 'Projeto prevê melhorias no asfalto, iluminação e paisagismo da importante via.',
        imageUrl: null,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: NewsCategory.infrastructure,
      ),
      NewsItem(
        title: 'Festival Cultural acontece no Bosque Maia neste fim de semana',
        description: 'Programação inclui shows, teatro e atividades para toda a família.',
        imageUrl: null,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: NewsCategory.events,
      ),
      NewsItem(
        title: 'Mutirão de limpeza será realizado no Parque Continental',
        description: 'Comunidade e prefeitura se unem para preservar área verde.',
        imageUrl: null,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        category: NewsCategory.general,
      ),
    ];
  }

  /// Filtra notícias por categoria
  static List<NewsItem> filterByCategory(
    List<NewsItem> news,
    NewsCategory category,
  ) {
    return news.where((item) => item.category == category).toList();
  }

  /// Busca notícias
  static List<NewsItem> searchNews(List<NewsItem> news, String query) {
    final lowercaseQuery = query.toLowerCase();
    return news.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             item.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

/// Categorias de notícias
enum NewsCategory {
  all,            // Todas
  general,        // Geral
  health,         // Saúde
  education,      // Educação
  security,       // Segurança
  transport,      // Transporte
  infrastructure, // Obras e Infraestrutura
  events,         // Eventos
}

extension NewsCategoryExtension on NewsCategory {
  String get name {
    switch (this) {
      case NewsCategory.all:
        return 'Todas';
      case NewsCategory.general:
        return 'Geral';
      case NewsCategory.health:
        return 'Saúde';
      case NewsCategory.education:
        return 'Educação';
      case NewsCategory.security:
        return 'Segurança';
      case NewsCategory.transport:
        return 'Transporte';
      case NewsCategory.infrastructure:
        return 'Obras';
      case NewsCategory.events:
        return 'Eventos';
    }
  }

  IconData get icon {
    switch (this) {
      case NewsCategory.all:
        return Icons.grid_view;
      case NewsCategory.general:
        return Icons.newspaper;
      case NewsCategory.health:
        return Icons.local_hospital;
      case NewsCategory.education:
        return Icons.school;
      case NewsCategory.security:
        return Icons.security;
      case NewsCategory.transport:
        return Icons.directions_bus;
      case NewsCategory.infrastructure:
        return Icons.construction;
      case NewsCategory.events:
        return Icons.event;
    }
  }

  Color get color {
    switch (this) {
      case NewsCategory.all:
        return const Color(0xFF2563EB);
      case NewsCategory.general:
        return const Color(0xFF6B7280);
      case NewsCategory.health:
        return const Color(0xFF4338CA);
      case NewsCategory.education:
        return const Color(0xFF059669);
      case NewsCategory.security:
        return const Color(0xFFF59E0B);
      case NewsCategory.transport:
        return const Color(0xFF7C3AED);
      case NewsCategory.infrastructure:
        return const Color(0xFFEA580C);
      case NewsCategory.events:
        return const Color(0xFFEC4899);
    }
  }
}

/// Modelo de notícia
class NewsItem {
  final String title;
  final String description;
  final String? imageUrl;
  final String? link;
  final DateTime publishedAt;
  final NewsCategory category;
  final bool isRead;

  NewsItem({
    required this.title,
    required this.description,
    this.imageUrl,
    this.link,
    required this.publishedAt,
    required this.category,
    this.isRead = false,
  });

  /// Retorna tempo relativo (ex: "há 2 horas")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(publishedAt);
    } else if (difference.inDays > 0) {
      return 'há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'agora';
    }
  }

  /// Cria cópia com novos valores
  NewsItem copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    DateTime? publishedAt,
    NewsCategory? category,
    bool? isRead,
  }) {
    return NewsItem(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }
}