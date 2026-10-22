import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:ido_prime/src/features/inspiration/models/mood_board.dart';

final moodBoardsProvider = NotifierProvider<MoodBoardsNotifier, List<MoodBoard>>(
  MoodBoardsNotifier.new,
);

class MoodBoardsNotifier extends Notifier<List<MoodBoard>> {
  @override
  List<MoodBoard> build() => List<MoodBoard>.from(seedMoodBoards);

  MoodBoard? byId(String id) {
    for (final board in state) {
      if (board.id == id) return board;
    }
    return null;
  }

  void saveLookToBoard(String boardId, String lookId) {
    state = [
      for (final board in state)
        if (board.id == boardId)
          board.copyWith(
            lookIds: board.lookIds.contains(lookId)
                ? board.lookIds
                : [...board.lookIds, lookId],
          )
        else
          board,
    ];
  }

  MoodBoard createBoard({
    required String name,
    required String coverUrl,
    String? eventId,
    String? eventTitle,
    String note = '',
    List<String> tags = const [],
    String? seedLookId,
  }) {
    final id = 'board-${DateTime.now().millisecondsSinceEpoch}';
    final lookIds = seedLookId == null ? <String>[] : [seedLookId];
    final board = MoodBoard(
      id: id,
      name: name.trim(),
      coverUrls: [coverUrl, coverUrl, coverUrl, coverUrl],
      lookIds: lookIds,
      eventId: eventId,
      eventTitle: eventTitle,
      blurb: note.trim().isEmpty
          ? (tags.isEmpty
                ? 'Your new mood board — start saving looks.'
                : 'A board focused on ${tags.join(', ').toLowerCase()}.')
          : note.trim(),
      tags: tags,
    );
    state = [...state, board];
    return board;
  }
}

InspirationLook? lookById(String id) => findInspirationLookById(id);

List<InspirationLook> looksForBoard(MoodBoard board) {
  return [
    for (final id in board.lookIds)
      ?findInspirationLookById(id),
  ];
}
