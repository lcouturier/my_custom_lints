// import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Cache manager pour stocker les résultats d'analyse
/// Cache manager pour stocker les résultats d'analyse
class LintCacheManager {
  static final Map<String, CacheEntry> _cache = {};
  static const int _cacheTtlMinutes = 10;

  static String generateHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    final now = DateTime.now();
    if (now.isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }

    return entry;
  }

  static void set(String key, List<LintIssue> issues) {
    final expiry = DateTime.now().add(const Duration(minutes: _cacheTtlMinutes));
    _cache[key] = CacheEntry(issues: issues, expiry: expiry);
  }

  static void clear() {
    _cache.clear();
  }

  /// Nettoie automatiquement les entrées expirées
  static void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiry));
  }

  /// Nettoie si le cache devient trop volumineux
  static void cleanIfNeeded({int maxEntries = 1000}) {
    cleanExpired();

    if (_cache.length > maxEntries) {
      // Garde seulement les entrées les plus récentes
      final sortedEntries = _cache.entries.toList()..sort((a, b) => b.value.expiry.compareTo(a.value.expiry));

      _cache.clear();
      for (int i = 0; i < maxEntries ~/ 2; i++) {
        final entry = sortedEntries[i];
        _cache[entry.key] = entry.value;
      }
    }
  }
}

/// Structure pour les entrées de cache
class CacheEntry {
  final List<LintIssue> issues;
  final DateTime expiry;

  CacheEntry({required this.issues, required this.expiry});
}

class LintIssue {
  final AstNode node;
  final String message;
  final String severity;

  LintIssue({required this.node, required this.message, required this.severity});
}

/// Gestionnaire d'événements pour contrôler le cache
class CacheEventHandler {
  /// À appeler lors du hot reload/restart
  static void onHotReload() {
    LintCacheManager.clear();
  }

  /// À appeler lors de changements de dépendances
  static void onDependenciesChanged() {
    LintCacheManager.clear();
  }

  /// À appeler périodiquement pour maintenir la performance
  static void onPeriodicCleanup() {
    LintCacheManager.cleanIfNeeded();
  }

  /// À appeler lors de changements de configuration lint
  static void onLintConfigChanged() {
    LintCacheManager.clear();
  }

  /// À appeler en cas de problème de mémoire
  static void onMemoryPressure() {
    LintCacheManager.clear();
  }
}
