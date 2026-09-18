import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/widgets/song_tile.dart';

void main() {
  testWidgets('SongTile renders title, artist and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    final track = Track(
      id: 'test_1',
      title: 'Midnight Campus Lo-Fi',
      artist: 'Resonance Focus Lab',
      streamUrl: 'https://example.com/audio.mp3',
      genre: 'Lo-Fi',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongTile(
            track: track,
            isPlaying: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Midnight Campus Lo-Fi'), findsOneWidget);
    expect(find.text('Resonance Focus Lab'), findsOneWidget);
    expect(find.text('Lo-Fi'), findsOneWidget);

    await tester.tap(find.byType(SongTile));
    expect(tapped, isTrue);
  });
}
