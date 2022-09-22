import 'package:bolao_app/src/features/login/data/storage_repository.dart';
import 'package:bolao_app/src/features/login/shared/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageController extends StateNotifier<AsyncValue<String?>> {
  StorageController({required this.storageRepository})
      : super(const AsyncData(null));

  final StorageRepository storageRepository;

  Future<void> save(String jwt) async {
    state = const AsyncLoading();

    final value = await AsyncValue.guard(() => storageRepository.save(jwt));
    if (value.hasError) {
      state = AsyncError(value.error!);
    } else {
      state = await AsyncValue.guard<String?>(() => storageRepository.read());
    }
  }

  Future<void> read() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard<String?>(() => storageRepository.read());
  }
}

final signInScreenControllerProvider =
    StateNotifierProvider.autoDispose<StorageController, AsyncValue<void>>(
        (ref) {
  return StorageController(storageRepository: ref.watch(storageProvider));
});
