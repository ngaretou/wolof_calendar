import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wolof_calendar/l10n/app_localizations.dart';

import '../providers/user_prefs.dart';
import '../providers/months.dart';

import 'month_header.dart';
import 'play_button.dart';

class ScripturePanel extends StatefulWidget {
  final Date currentDate;
  final List<Month> monthData;
  final double contentColWidth;
  final double headerImageHeight;
  final double scripturePanelWidth;
  final EdgeInsets adaptiveMargin;
  final Size size;
  final bool isPhone;
  final bool kIsWeb;

  const ScripturePanel({
    super.key,
    required this.currentDate,
    required this.monthData,
    required this.contentColWidth,
    required this.headerImageHeight,
    required this.scripturePanelWidth,
    required this.adaptiveMargin,
    required this.size,
    required this.isPhone,
    required this.kIsWeb,
  });

  @override
  State<ScripturePanel> createState() => _ScripturePanelState();
}

class _ScripturePanelState extends State<ScripturePanel> {
  // this is how the parent triggers a function in this child widget
  final ChildController childController = ChildController();
  ValueNotifier<bool> showButtonNotifier = ValueNotifier(false);
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  @override
  void dispose() {
    showButtonNotifier.dispose();
    draggableScrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserPrefs userPrefs = Provider.of<UserPrefs>(
      context,
      listen: false,
    ).userPrefs;
    final monthData = Provider.of<Months>(context, listen: false)
        .months
        .where((month) => month.monthID == widget.currentDate.month)
        .toList();

    //this is the share and play buttons at bottom of scripture panel
    Widget buttonsRow() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filled(
            icon: const Icon(Icons.share),
            onPressed: () {
              //Grab the months data, which contains the verse data
              Month monthData = (Provider.of<Months>(context, listen: false)
                  .months
                  .where(
                    (element) => element.monthID == widget.currentDate.month,
                  )
                  .toList()[0]);
              //the [0] grabs the first in the list, which will be the only one
              triggerSharing(context, kIsWeb, monthData);
            },
          ),
          PlayButton(
            file: widget.currentDate.month,
            childController: childController,
          ),
        ],
      );
    }

    Widget versesComposer() {
      return MonthHeader(
        currentDate: widget.currentDate,
        monthData: monthData,
        contentColWidth: widget.contentColWidth,
        headerImageHeight: widget.headerImageHeight,
        adaptiveMargin: widget.adaptiveMargin,
        isPhone: widget.isPhone,
        kIsWeb: widget.kIsWeb,
        scriptureOnly: true,
        showCardBackground: false,
      );
    }

    Widget scripturePanelContents(ScrollController scrollController) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
        child: BackdropFilter(
          filter: userPrefs.glassEffects!
              ? ImageFilter.blur(sigmaX: 50, sigmaY: 50)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Stack(
            children: [
              if (!userPrefs.glassEffects!)
                Container(
                    color: Theme.of(context).colorScheme.surfaceContainer),
              ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const Center(child: Icon(Icons.drag_handle_rounded)),
                    versesComposer(),
                    // const SizedBox(height: 10), // space for buttons
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    draggableScrollableController.addListener(() {
      // print(
      //   'draggableScrollableController.size: ${draggableScrollableController.size}',
      // );
      if (draggableScrollableController.size > 0.3) {
        // print('show buttons');
        showButtonNotifier.value = true;
      } else {
        // print('hide buttons');
        showButtonNotifier.value = false;
      }
    });

    const double smallestPanelHeight = .18;

    //phone setup as bottom sheet
    return widget.isPhone
        ? Stack(
            children: [
              DraggableScrollableSheet(
                expand: true,
                snap: true,
                snapSizes: const [smallestPanelHeight, .8],
                initialChildSize: smallestPanelHeight,
                minChildSize: smallestPanelHeight,
                maxChildSize: kIsWeb ? .93 : .95,
                controller: draggableScrollableController,

                // no way to get SafeArea consistently so go to 95%
                // don't want handle to get hidden behind state bar
                shouldCloseOnMinExtent: false,
                builder: (context, scrollController) =>
                    scripturePanelContents(scrollController),
              ),
              Positioned(
                left: 0,
                bottom: 20,
                child: ValueListenableBuilder(
                  valueListenable: showButtonNotifier,
                  builder: (context, value, child) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      // opacity: buttonsVisible ? 1 : 0,
                      opacity: showButtonNotifier.value == false ? 0 : 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: widget.size.width,
                        child: buttonsRow(),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        //dates side by side with verses display for widescreen
        : Stack(
            children: [
              SizedBox(
                height: double.infinity,
                child: ScrollConfiguration(
                  //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
                  behavior: MyCustomScrollBehavior(),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Center(
                      child: SingleChildScrollView(
                        // physics: const AlwaysScrollableScrollPhysics(),
                        child: versesComposer(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: SizedBox(
                  width: widget.scripturePanelWidth - 40,
                  child: buttonsRow(),
                ),
              ),
            ],
          );
  }
}

void triggerSharing(BuildContext context, bool kIsWeb, Month monthData) {
  Size size = MediaQuery.of(context).size;
  /*
now sharing audio, but with a caveat. 
See https://github.com/fluttercommunity/plus_plugins/issues/413
Facebook has his own sharing SDK, which is problematic because it doesn't respect the native platform intents. 
If you share text + audio to FB/WA etc, It only shares the audio file and not the text. 
So we give the user three choices, audio, Arabic, or Roman. 
If the user is sharing to Facebook, or WhatsApp, then everything works as intended. 
If they are sharing audio, and not sharing to an FB product, they'll get the audio and the Roman script.
This is a hack to get around FB's unneighborly behavior. 
*/

  //the function that runs after the user makes a choice below
  void adaptiveShare(String script) async {
    String versesToShare = '';
    String vs = '', ref = '';
    String lineBreak = '\n';

    //Put together the verses to share. Do with forEach to take into account the multiple verse months.
    for (var element in monthData.verses) {
      // monthData.verses.forEach((element) {
      if (script == 'roman' || script == 'audio') {
        vs = element.verseRS;
        ref = element.verseRefRS;
      } else if (script == 'arabic') {
        vs = element.verseAS;
        ref = element.verseRefAS;
      }

      versesToShare =
          versesToShare + vs + lineBreak + ref + lineBreak + lineBreak;
    }

    //Put together the whole sharing string
    final String textToShare = '${versesToShare}https://sng.al/cal';

    //if it's not the web app, share using the device share function
    // if (!kIsWeb) {
    if (script == 'audio') {
      //The docs for this plugin say you should be able to just pass in the path directly, but can't get that to work.
      //so do all this writing a temp file so as to be able to share the audio.

      final byte = (await rootBundle.load(
        'assets/audio/${monthData.monthID}.mp3',
      ))
          .buffer
          .asUint8List(); // convert in to Uint8List
      if (kIsWeb) {
        // https://github.com/fluttercommunity/plus_plugins/issues/1643
        await XFile.fromData(
          Uint8List.fromList(byte),
          mimeType: 'audio/mpeg',
        ).saveTo('aaya.mp3');
      } else {
        final dir = await getTemporaryDirectory();
        try {
          final file = File("${dir.path}/aaya.mp3"); // import 'dart:io'
          await file.writeAsBytes(byte);

          // Share
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: textToShare,
              sharePositionOrigin: Rect.fromLTWH(
                0,
                0,
                size.width,
                size.height * .33,
              ),
            ),
          );

          //clean up the temp file
          file.delete();
        } catch (e) {
          debugPrint(e.toString());
          debugPrint('problem sharing audio file, sharing text only');

          await SharePlus.instance.share(
            ShareParams(
              text: textToShare,
              sharePositionOrigin: Rect.fromLTWH(
                0,
                0,
                size.width,
                size.height * .33,
              ),
            ),
          );
        }
      }
    } else {
      await SharePlus.instance.share(
        ShareParams(
          text: textToShare,
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height * .33,
          ),
        ),
      );
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.sharingTitle),
        content: Text(AppLocalizations.of(context)!.sharingMsg),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.audio),
                onPressed: () async {
                  Navigator.of(context).pop();
                  adaptiveShare('audio');
                },
              ),
              TextButton(
                child: const Text("Wolof"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  adaptiveShare('roman');
                },
              ),
              TextButton(
                child: const Text(
                  " وࣷلࣷفَلْ ",
                  style: TextStyle(fontFamily: "Harmattan", fontSize: 22),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  adaptiveShare('arabic');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//For calling the child method from the parent - follow the childController text through this and player_button.dart
class ChildController {
  void Function() childMethod = () {};
}

// The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
