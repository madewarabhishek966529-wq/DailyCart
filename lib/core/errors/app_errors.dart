// DailyCart - App Errors
abstract class AppError implements Exception {
  const AppError(this.message);
  final String message;
  @override
  String toString() => message;
}

class DatabaseError extends AppError {
  const DatabaseError(super.message);
}

class ValidationError extends AppError {
  const ValidationError(super.message);
}

class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

class BackupError extends AppError {
  const BackupError(super.message);
}

DatabaseError mapDbException(Object e) {
  final msg = e.toString();
  if (msg.contains('UNIQUE constraint')) {
    return const DatabaseError('An item with this name already exists.');
  } else if (msg.contains('FOREIGN KEY constraint')) {
    return const DatabaseError('This item is linked to other data.');
  } else if (msg.contains('no such table')) {
    return const DatabaseError(
      'Database structure error. Please restart the app.',
    );
  }
  return const DatabaseError('A database error occurred. Please try again.');
}
