import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'A server error occurred. Please try again later.'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'You must be logged in to perform this action.'});
}

class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure({super.message = 'The requested file could not be found.'});
}

class StorageFailure extends Failure {
  const StorageFailure({super.message = 'Not enough space or permission denied to save file.'});
}

class ProcessingFailure extends Failure {
  const ProcessingFailure({super.message = 'Failed to process the PDF document.'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied.'});
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure({super.message = 'Failed to verify subscription or complete purchase.'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred.'});
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'A cache error occurred.']) : super(message: message);
}
