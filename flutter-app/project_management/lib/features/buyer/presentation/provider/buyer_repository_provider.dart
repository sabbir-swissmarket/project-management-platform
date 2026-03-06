import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_management/core/network/dio_provider.dart';

import '../../data/repositories/buyer_repository_impl.dart';
import '../../domain/repositories/buyer_repository.dart';

final buyerRepositoryProvider = Provider<BuyerRepository>((ref) {
  final dio = DioProvider.createDio();
  return BuyerRepositoryImpl(dio);
});
