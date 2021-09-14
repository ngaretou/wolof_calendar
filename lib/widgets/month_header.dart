import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../providers/months.dart';
import '../providers/user_prefs.dart';
// import 'package:intl/intl.dart';

class MonthHeader extends StatefulWidget {
  final Date currentDate;
  final List<Month> monthData;
  MonthHeader({Key? key, required this.currentDate, required this.monthData})
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

    //viewing setup
    final _screenwidth = MediaQuery.of(context).size.width;
    final bool _isPhone =
        (_screenwidth + MediaQuery.of(context).size.height) <= 1400;

    // Column width for the name row
    var _contentColWidth;
    if (kIsWeb && _screenwidth > 1000) {
      _contentColWidth = 800;
    } else {
      _contentColWidth = _screenwidth;
    }

    var _nameColWidth = (_contentColWidth / 2) - 20;
    //end viewing setup
    var userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;

    // ignore: unused_element
    void _adaptiveShare(String script, List<Verses> verses) async {
      String versesToShare = '';
      late String lineBreak, yallaMooy, vs, ref, name;

      kIsWeb ? lineBreak = '%0d%0a' : lineBreak = '\n';

      //Put together the verses to share. Do with forEach to take into account the multiple verse months.
      widget.monthData[0].verses.forEach((element) {
        if (script == 'roman') {
          yallaMooy = 'Yàlla mooy ';
          vs = element.verseRS;
          ref = element.verseRefRS;
          name = widget.monthData[0].wolofName;
        } else if (script == 'arabic') {
          yallaMooy = 'يࣵلَّ مࣷويْ ';
          vs = element.verseAS;
          ref = element.verseRefAS;
          name = widget.monthData[0].wolofalName;
        }

        versesToShare =
            versesToShare + vs + lineBreak + ref + lineBreak + lineBreak;
      });

      //Put together the whole sharing string
      final String textToShare = yallaMooy +
          name +
          ": " +
          lineBreak +
          lineBreak +
          versesToShare +
          'https://sng.al/cal';

      //if it's not the web app, share using the device share function
      if (!kIsWeb) {
        Share.share(textToShare);
      } else {
        //If it's the web app version best way to share is probably email, so put the text to share in an email
        final String url = "mailto:?subject=Arminaatu Wolof&body=$textToShare";

        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    } //adaptive share method

    EdgeInsets adaptivePadding = _isPhone
        ? EdgeInsets.symmetric(horizontal: 10, vertical: 10)
        : EdgeInsets.symmetric(horizontal: _screenwidth / 20, vertical: 0);

    //Now build the month expandable header
    return Column(
      children: [
        //Image header
        Container(
          margin: EdgeInsets.only(top: 10),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black54,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                  "assets/images/${widget.monthData[0].monthID}.jpg"),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              widget.monthData[0].arabicName,
              style: asHeaderStyle.copyWith(color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: adaptivePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: _nameColWidth,
                  child: Text(widget.monthData[0].wolofName,
                      style: rsHeaderStyle)),
              Container(
                width: _nameColWidth,
                child: Text(
                  widget.monthData[0].wolofalName,
                  style: asHeaderStyle,
                  textDirection: ui.TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),

        ExpansionTile(
            leading: Icon(
              Icons.fingerprint,
              size: 40,
            ),
            title: verseIsExpanded!
                ? Text('')
                : Text(AppLocalizations.of(context)!.clickHereToReadMore,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontStyle: FontStyle.italic)),
            initiallyExpanded: true,
            onExpansionChanged: (bool) {
              setState(() {
                verseIsExpanded = !verseIsExpanded!;
              });
            },
            backgroundColor: Theme.of(context).cardColor,
            collapsedBackgroundColor: Theme.of(context).cardColor,
            // iconColor: Theme.of(context).accentColor,
            // collapsedIconColor: Theme.of(context).accentColor,
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
                      adaptivePadding),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),

              if (userPrefs.wolofalVerseEnabled! &&
                  userPrefs.wolofVerseEnabled!)
                Divider(
                  height: 60,
                  thickness: 2,
                  // color: Theme.of(context).accentColor,
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
                      adaptivePadding),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              SizedBox(height: 20),
              //End verses

              //Click here to read more button
              Container(
                margin: _isPhone
                    ? EdgeInsets.symmetric(horizontal: 40)
                    : EdgeInsets.symmetric(horizontal: _contentColWidth / 4),
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.clickHereToReadMore,
                        // style: Theme.of(context)
                        //     .appBarTheme
                        //     .textTheme!
                        //     .headline6!
                        //     .copyWith(fontSize: 18)
                      ),
                      Icon(
                        Icons.arrow_forward,
                        // color:
                        //     Theme.of(context).appBarTheme.iconTheme!.color
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
            ]),

        //Here is the first Row of the informational month header:
        //the RS Western and Wolofal months
        Container(
          padding: adaptivePadding,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.monthData[0].monthRS, style: headerStyle),
            Text(widget.currentDate.wolofMonthRS, style: headerStyle),
          ]),
        ),
        Container(
          padding: adaptivePadding,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              widget.monthData[0].monthAS,
              style: headerStyle,
              textDirection: ui.TextDirection.rtl,
            ),
            Text(
              widget.currentDate.wolofMonthAS ?? '',
              style: headerStyle,
              textDirection: ui.TextDirection.rtl,
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
  final EdgeInsets adaptivePadding;

  VerseBuilder(this.verse, this.ref, this.verseStyle, this.refStyle,
      this.direction, this.numItems, this.i, this.adaptivePadding);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: adaptivePadding,
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
              thickness: 1, height: 60,
              // color: Theme.of(context).accentColor
            )
        ],
      ),
    );
  }
}
