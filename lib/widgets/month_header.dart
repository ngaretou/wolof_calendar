import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/months.dart';
import '../providers/user_prefs.dart';

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

  MonthHeader(
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
  _MonthHeaderState createState() => _MonthHeaderState();
}

class _MonthHeaderState extends State<MonthHeader> {
  bool? verseIsExpanded;
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
        color: Theme.of(context).textTheme.headline6!.color);
    TextStyle asStyle = Theme.of(context).textTheme.headline6!.copyWith(
          fontFamily: "Harmattan",
          fontSize: 40,
        );
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontFamily: "Charis", fontSize: 30);

    TextStyle asRefStyle = asStyle.copyWith(fontSize: 24);
    TextStyle rsRefStyle = rsStyle.copyWith(fontSize: 18);

    TextStyle asHeaderStyle = asStyle.copyWith(fontSize: 46, height: 1.5);
    TextStyle rsHeaderStyle = rsStyle.copyWith(fontSize: 36, height: 1.7);

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;
    //End text styles

    final double _nameColWidth = (widget.contentColWidth / 2);

    var userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;

    /* Fall 2021 Flutter 2.5.1, the AS text boxes get squished by Flutter on on web. 
    Assuming this will get fixed in a future release. 
    This rtlTextFixer hacks any RTL text with a space on either side only if on web. 
     */
    String rtlTextFixer(String textToFix) {
      late String _correctedText;
      if (widget.kIsWeb) {
        _correctedText = ' ' + textToFix + ' ';
      } else {
        _correctedText = textToFix;
      }
      return _correctedText;
    }

    //Now build the month expandable header
    return Column(
      children: [
        //Image header
        Container(
            margin: EdgeInsets.only(top: 10),
            height: widget.headerImageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
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
              child: widget.monthData[0].arabicName != null
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        widget.monthData[0].arabicName.toString(),
                        style: asHeaderStyle.copyWith(color: Colors.white),
                      ),
                    )
                  : SizedBox(),
            )),
        //Main name row
        Padding(
          padding: widget.adaptiveMargin,
          // padding: EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: _nameColWidth,
                  child: Text(widget.monthData[0].wolofName.toString(),
                      style: rsHeaderStyle)),
              Container(
                width: _nameColWidth,
                child: Text(
                  widget.monthData[0].wolofalName.toString(),
                  style: asHeaderStyle,
                  textDirection: ui.TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),

        ExpansionTile(
          title: Text(''),
          initiallyExpanded: true,
          onExpansionChanged: (bool) {
            setState(() {
              verseIsExpanded = !verseIsExpanded!;
            });
          },
          collapsedBackgroundColor: Theme.of(context).cardColor,
          children: [
            //Begin verses: Wolofal first, then Roman
            if (userPrefs.wolofalVerseEnabled!)
              ListView.builder(
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
                physics: NeverScrollableScrollPhysics(),
              ),

            if (userPrefs.wolofalVerseEnabled! && userPrefs.wolofVerseEnabled!)
              Divider(
                height: 60,
                thickness: 2,
              ),

            //RS verses
            if (userPrefs.wolofVerseEnabled!)
              ListView.builder(
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
                physics: NeverScrollableScrollPhysics(),
              ),
            SizedBox(height: 20),
            //End verses

            //Click here to read more button
            Container(
              padding: widget.isPhone
                  ? EdgeInsets.symmetric(horizontal: 40)
                  : EdgeInsets.symmetric(
                      horizontal: (widget.contentColWidth) / 4),
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.clickHereToReadMore,
                    ),
                    Icon(
                      Icons.arrow_forward,
                    ),
                  ],
                ),
                onPressed: () async {
                  const url = 'https://sng.al/chrono';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),

        //Here is the first Row of the simple informational month header:
        //the RS Western and Wolofal months
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: (widget.adaptiveMargin.horizontal / 2) + 5.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.monthData[0].monthRS, style: headerStyle),
            Text(widget.currentDate.wolofMonthRS.toString(),
                style: headerStyle),
          ]),
        ),
        //Second row, AS month names
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: (widget.adaptiveMargin.horizontal / 2) + 5.0),
          child:
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
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: (widget.adaptiveMargin.horizontal / 2) + 5.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              widget.currentDate.year,
              style: headerStyle,
            ),
          ]),
        )
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

  VerseBuilder(this.verse, this.ref, this.verseStyle, this.refStyle,
      this.direction, this.numItems, this.i, this.adaptiveMargin);

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
          Divider(
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
            Divider(
              thickness: 1,
              height: 60,
            )
        ],
      ),
    );
  }
}
