class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateColorException extends CloudStorageException {}

class CouldNotGetAllColorsException extends CloudStorageException {}

class CouldNotUpdateColorException extends CloudStorageException {}

class CouldNotDeleteColorException extends CloudStorageException {}
