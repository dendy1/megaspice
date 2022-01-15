import 'dart:io';

abstract class BaseStorageRepo {
  Future<String> uploadProfileImageAndGiveUrl({
    required String url,
    required File image,
  });

  Future<String> uploadPostImageAndGiveUrl({
    required File image,
  });
}
