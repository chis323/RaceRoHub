class InvalidPasswordException implements Exception {
  final String message;
  InvalidPasswordException([this.message = 'Invalid password']);
  @override
  String toString() => message;
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException([this.message = 'User not found']);
  @override
  String toString() => message;
}

class UserConflictException implements Exception {
  final String message;
  UserConflictException([this.message = 'Username already exists']);
  @override
  String toString() => message;
}
