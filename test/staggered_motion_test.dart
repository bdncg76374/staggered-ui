import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staggered_ui/staggered_ui.dart';

Widget _list({required bool disableAnimations}) => MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: StaggeredListView(
          timing: const StaggerTiming(
            itemCount: 3,
            itemDuration: Duration(milliseconds: 200),
            step: Duration(milliseconds: 50),
          ),
          itemCount: 3,
          itemBuilder: (context, index, animation) => const SizedBox(height: 40),
        ),
      ),
    );

void main() {
  testWidgets('reduced motion resolves to the reduced setting', (tester) async {
    late BuildContext inner;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              inner = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(StaggeredMotion.of(inner), StaggeredMotion.reduced);
    expect(StaggeredMotion.of(inner).translate, isFalse);
  });

  testWidgets('reduced motion lays rows out at their end state', (tester) async {
    await tester.pumpWidget(_list(disableAnimations: true));
    await tester.pump();

    expect(find.byType(SlideTransition), findsNothing);
    final fade = tester.widget<FadeTransition>(find.byType(FadeTransition).first);
    expect(fade.opacity.value, 1);
  });

  testWidgets('full motion still slides rows in', (tester) async {
    await tester.pumpWidget(_list(disableAnimations: false));
    await tester.pump();

    expect(find.byType(SlideTransition), findsWidgets);
  });
}
