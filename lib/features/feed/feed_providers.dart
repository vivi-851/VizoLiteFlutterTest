import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'feed_repository.dart';
import 'market.dart';

final feedRepoProvider =
    Provider<FeedRepository>((ref) => FeedRepository(Supabase.instance.client));

final feedProvider = FutureProvider<List<Market>>(
    (ref) => ref.read(feedRepoProvider).fetchFeed());

final marketProvider = FutureProvider.family<Market?, String>(
    (ref, id) => ref.read(feedRepoProvider).fetchOne(id));
