import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/party_repository.dart';
import '../../../core/network/providers.dart';

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PartyRepository(dio);
});