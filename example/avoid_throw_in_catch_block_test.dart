void repository() {
  try {
    networkDataProvider();
  } on Object {
    throw RepositoryException(); // LINT: Avoid 'throw' inside a catch block as it causes the original stack trace and the original exception to be lost. Try using 'rethrow or 'Error.throwWithStackTrace'.
  }
}

class RepositoryException implements Exception {
  const RepositoryException();
}

void networkDataProvider() {}
