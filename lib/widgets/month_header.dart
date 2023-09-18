// ignore_for_file: sized_box_for_whitespace

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/months.dart';
import '../providers/user_prefs.dart';
// import 'glass_card.dart';

//month_header is everything from the picture down to the month and year text in the list of days

//We're feeding in all this info so that the widget tree doesn't have to rebuild
////and the code is a bit more efficient, although makes for a messy constructor
class MonthHeader extends StatefulWidget {
  final Date currentDate;
  final List<Month> monthData;
  final double contentColWidth;
  final double headerImageHeight;
  final EdgeInsets adaptiveMargin;
  final bool isPhone;
  final bool kIsWeb;
  final bool scriptureOnly;
  final bool showCardBackground;

  const MonthHeader(
      {Key? key,
      required this.currentDate,
      required this.monthData,
      required this.contentColWidth,
      required this.headerImageHeight,
      required this.adaptiveMargin,
      required this.isPhone,
      required this.kIsWeb,
      required this.scriptureOnly,
      required this.showCardBackground})
      : super(key: key);

  @override
  MonthHeaderState createState() => MonthHeaderState();
}

class MonthHeaderState extends State<MonthHeader> {
  ScrollController wolofalScrollController = ScrollController();
  ScrollController wolofScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    //Overlay color for the image
    final Color overlayColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    //Styling that gets reused a few times
    const double headerBorderRadius = 20;

    //Text Styles
    TextStyle headerStyle = TextStyle(
        fontFamily: "Harmattan",
        fontSize: 30,
        color: Theme.of(context).textTheme.titleLarge!.color);
    TextStyle asStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontFamily: "Harmattan",
          fontSize: 40,
        );
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontFamily: "Charis", fontSize: 30);

    TextStyle asRefStyle = asStyle.copyWith(fontSize: 24);
    TextStyle rsRefStyle = rsStyle.copyWith(fontSize: 18);

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;
    //End text styles

    UserPrefs userPrefs =
        Provider.of<UserPrefs>(context, listen: false).userPrefs;

    /* Fall 2021 Flutter 2.5.1, the AS text boxes get squished by Flutter only on web. 
    Assuming this will get fixed in a future release. 
    This rtlTextFixer hacks any RTL text with a space on either side only if on web, which fixes it. 
     */
    String rtlTextFixer(String textToFix) {
      late String correctedText;
      if (widget.kIsWeb || Platform.isIOS || Platform.isAndroid) {
        correctedText = '$textToFix ';
      } else {
        correctedText = textToFix;
      }
      return correctedText;
    }

    // date-related info
    List<Widget> dateWidgets = [
      //Here is the first Row of the simple informational month header:
      //the RS Western and Wolofal months
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.monthData[0].monthRS, style: headerStyle),
        Text(widget.currentDate.wolofMonthRS.toString(), style: headerStyle),
      ]),

      //Second row, AS month names
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          rtlTextFixer(widget.monthData[0].monthAS),
          style: headerStyle,
          textDirection: ui.TextDirection.rtl,
        ),
        Text(
          rtlTextFixer(widget.currentDate.wolofMonthAS.toString()),
          style: headerStyle,
          textDirection: ui.TextDirection.rtl,
        ),
      ]),

      //year
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.currentDate.year,
            style: headerStyle,
          ),
        ],
      ),
      // if (userPrefs.wolofalVerseEnabled!)
      //   const Divider(
      //     thickness: 2,
      //   ),
    ];

    //scripture related info
    List<Widget> scriptureWidgets = [
      //Begin verses: Wolofal first, then Roman
      if (userPrefs.wolofalVerseEnabled!)
        ListView.builder(
          padding: const EdgeInsets.all(0),
          // controller: wolofalScrollController,
          itemCount: widget.monthData[0].verses.length,
          itemBuilder: (ctx, i) => VerseBuilder(
              widget.monthData[0].verses[i].verseAS,
              widget.monthData[0].verses[i].verseRefAS,
              asStyle,
              asRefStyle,
              rtlText,
              widget.monthData[0].verses.length,
              i,
              widget.adaptiveMargin),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),

      if (userPrefs.wolofalVerseEnabled! && userPrefs.wolofVerseEnabled!)
        const Divider(
          height: 60,
          thickness: 2,
        ),

      //RS verses
      if (userPrefs.wolofVerseEnabled!)
        ListView.builder(
          padding: const EdgeInsets.all(0),
          // controller: wolofScrollController,
          itemCount: widget.monthData[0].verses.length,
          itemBuilder: (ctx, i) => VerseBuilder(
              widget.monthData[0].verses[i].verseRS,
              widget.monthData[0].verses[i].verseRefRS,
              rsStyle,
              rsRefStyle,
              ltrText,
              widget.monthData[0].verses.length,
              i,
              widget.adaptiveMargin),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      const SizedBox(height: 20),
      //End verses

      //Click here to read more button
      Container(
        padding: widget.isPhone
            ? const EdgeInsets.symmetric(horizontal: 10)
            : EdgeInsets.symmetric(horizontal: widget.adaptiveMargin.left),
        child: Center(
          child: FilledButton(
            child: Text(
              AppLocalizations.of(context)!.clickHereToReadMore,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Expanded(
            //       child:
            //     ),
            //     // const Icon(
            //     //   Icons.arrow_forward,
            //     // ),
            //   ],
            // ),
            onPressed: () async {
              const url = 'https://sng.al/chrono';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
    ];


    //this is all about getting the spacing right going between the phone and widescreen versions. 
    late EdgeInsetsGeometry headerPadding;
    if (widget.isPhone || !widget.scriptureOnly) {
      headerPadding = widget.adaptiveMargin;
    } else {
      headerPadding = widget.adaptiveMargin.copyWith(top: 90);
    }

    //Now build the month header
    return Padding(
      padding: headerPadding,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          //Image header
          !widget.scriptureOnly
              ? Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: widget.headerImageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(headerBorderRadius),
                    image: DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      image: AssetImage(
                          "assets/images/${widget.monthData[0].monthID}.jpg"),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(headerBorderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          overlayColor.withOpacity(.8),
                          overlayColor.withOpacity(.5)
                        ],
                        stops: const [0, .9],
                      ),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 10,
                ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.scriptureOnly ? scriptureWidgets : dateWidgets,
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: widget.showCardBackground
          //         ? Theme.of(context).colorScheme.primaryContainer
          //         : Colors.transparent,
          //     borderRadius: const BorderRadius.only(
          //         bottomLeft: Radius.circular(40),
          //         bottomRight: Radius.circular(40)),
          //   ),

          //   // GlassCard(
          //   // showGradient: false,
          //   // borderColor: Theme.of(context).cardColor.withOpacity(.2),
          //   child:
          // ),
        ],
      ),
    );
  }
}

class VerseBuilder extends StatelessWidget {
  final String verse;
  final String ref;
  final TextStyle verseStyle;
  final TextStyle refStyle;
  final ui.TextDirection direction;
  final int numItems;
  final int i;
  final EdgeInsets adaptiveMargin;

  const VerseBuilder(this.verse, this.ref, this.verseStyle, this.refStyle,
      this.direction, this.numItems, this.i, this.adaptiveMargin,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: adaptiveMargin,
      // padding: EdgeInsets.all(0),
      child: Column(
        children: [
          Text(
            verse,
            style: verseStyle,
            textDirection: direction,
            textAlign: TextAlign.center,
          ),
          const Divider(
            height: 30,
            thickness: 1,
            indent: 50,
            endIndent: 50,
          ),
          Text(
            ref,
            style: refStyle,
            textDirection: direction,
            textAlign: TextAlign.center,
          ),
          if (numItems - i != 1)
            const Divider(
              thickness: 1,
              height: 60,
            )
        ],
      ),
    );
  }
}
