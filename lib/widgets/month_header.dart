// ignore_for_file: sized_box_for_whitespace

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/months.dart';
import '../providers/user_prefs.dart';

//month_header is everything from the picture down to the month and year text in the list of days

//We're feeding in all this info so that the widget tree doesn't have to rebuild
////and the code is a bit more efficient, although makes for a messy constructor
class MonthHeader extends StatefulWidget {
  final Date currentDate;
  final List<Month> monthData;
  final double contentColWidth;
  final double headerImageHeight;
  final EdgeInsets adaptiveMargin;
  final double screenWidth;
  final bool isPhone;
  final bool kIsWeb;

  const MonthHeader(
      {Key? key,
      required this.currentDate,
      required this.monthData,
      required this.contentColWidth,
      required this.headerImageHeight,
      required this.adaptiveMargin,
      required this.screenWidth,
      required this.isPhone,
      required this.kIsWeb})
      : super(key: key);

  @override
  MonthHeaderState createState() => MonthHeaderState();
}

class MonthHeaderState extends State<MonthHeader> {
  bool? verseIsExpanded;
  ScrollController wolofalScrollController = ScrollController();
  ScrollController wolofScrollController = ScrollController();

  @override
  void initState() {
    verseIsExpanded = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    var userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;

    /* Fall 2021 Flutter 2.5.1, the AS text boxes get squished by Flutter only on web. 
    Assuming this will get fixed in a future release. 
    This rtlTextFixer hacks any RTL text with a space on either side only if on web. 
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

    //Now build the month expandable header
    return Column(
      children: [
        //Image header
        Container(
          margin: const EdgeInsets.only(top: 10),
          height: widget.headerImageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black87,
            //The month header image
            image: DecorationImage(
              alignment: Alignment.center,
              fit: BoxFit.cover,
              image: AssetImage(
                  "assets/images/${widget.monthData[0].monthID}.jpg"),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.7),
                  Colors.black.withOpacity(.0)
                ],
              ),
            ),
          ),
        ),

        //Main month row
        Padding(
          padding: widget.adaptiveMargin,
          // padding: EdgeInsets.only(top: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Here is the first Row of the simple informational month header:
              //the RS Western and Wolofal months

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(widget.monthData[0].monthRS, style: headerStyle),
                Text(widget.currentDate.wolofMonthRS.toString(),
                    style: headerStyle),
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
            ],
          ),
        ),

        // Start of verses
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
          child: ExpansionTile(
            title: const Text(''),
            initiallyExpanded: true,
            onExpansionChanged: (_) {
              setState(() {
                verseIsExpanded = !verseIsExpanded!;
              });
            },
            collapsedBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            children: [
              //Begin verses: Wolofal first, then Roman
              if (userPrefs.wolofalVerseEnabled!)
                ListView.builder(
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

              if (userPrefs.wolofalVerseEnabled! &&
                  userPrefs.wolofVerseEnabled!)
                const Divider(
                  height: 60,
                  thickness: 2,
                ),

              //RS verses
              if (userPrefs.wolofVerseEnabled!)
                ListView.builder(
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
                    ? const EdgeInsets.symmetric(horizontal: 40)
                    : EdgeInsets.symmetric(
                        horizontal: widget.adaptiveMargin.left + 150),
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.clickHereToReadMore,
                      ),
                      const Icon(
                        Icons.arrow_forward,
                      ),
                    ],
                  ),
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
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
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
