class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erreur serveur.']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion.']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Erreur d\'authentification.']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erreur de cache.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Ressource introuvable.']);
}
