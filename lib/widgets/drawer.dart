// ignore_for_file: sized_box_for_whitespace
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextStyle whiteHeadline6 =
        Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white);

    //Main template for all titles
    Widget drawerTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
            width: 300,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    icon.toString().startsWith("FontAwesomeIcons")
                        ? FaIcon(icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color)
                        : Icon(
                            icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                          ),
                    const SizedBox(width: 25),
                    Text(title, style: whiteHeadline6),
                  ],
                ))),
      );
    }

    return Drawer(
      elevation: 5.0,
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        //The color of the Drawer
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: ListView(
          children: [
            //Main title

            Padding(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendar,
                    size: 27,
                    color: Theme.of(context).appBarTheme.iconTheme!.color,
                  ),
                  const SizedBox(width: 25),
                  Text("Arminaatu wolof",
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: Colors.white)),
                ],
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            drawerTitle(
              AppLocalizations.of(context)!.settingsTitle,
              Icons.settings,
              () {
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),

            const Divider(
              thickness: 1,
            ),
            drawerTitle(
              // 'Add holidays to\nGoogle Calendar TT',
              AppLocalizations.of(context)!.addHolidays,
              Icons.calendar_today,
              () async {
                late String url;

                if (Platform.isIOS) {
                  //iCal format for iOS
                  url =
                      'https://calendar.google.com/calendar/ical/5islvfeuls670m9ckvpop40ao4%40group.calendar.google.com/public/basic.ics';
                } else {
                  //Direct add
                  url =
                      'https://calendar.google.com/calendar/u/0/r?cid=5islvfeuls670m9ckvpop40ao4@group.calendar.google.com';
                }

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),

            const Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalizations.of(context)!.shareAppLink,
              Icons.share,
              () async {
                Navigator.of(context).pop();
                if (!kIsWeb) {
                  Share.share('https://sng.al/cal');
                } else {
                  const url =
                      "mailto:?subject=Arminaatu Wolof&body=Xoolal appli Arminaatu Wolof fii: https://sng.al/cal";

                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                }
              },
            ),
            const Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalizations.of(context)!.moreApps,
              Icons.web_asset,
              () async {
                const url = 'https://sng.al/app';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            //Contact Us section
            const Divider(
              thickness: 2,
            ),

            Container(
                width: 300,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.settingsContactUs,
                            style: whiteHeadline6),
                      ],
                    ))),

            // drawerTitle(
            //     AppLocalizations.of(context).settingsContactUs, null, null),
            drawerTitle(
              AppLocalizations.of(context)!.settingsContactUsEmail,
              Icons.email,
              () async {
                const url = 'mailto:equipedevmbs@gmail.com';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),

            drawerTitle(
              AppLocalizations.of(context)!.contactWhatsApp,
              FontAwesomeIcons.whatsapp,
              () async {
                const url = 'https://wa.me/221776427432';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            drawerTitle(
              AppLocalizations.of(context)!.contactFBMessenger,
              FontAwesomeIcons.facebookMessenger,
              () async {
                const url = 'https://m.me/buleenragal/';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            const Divider(
              thickness: 2,
            ),
            drawerTitle(
              AppLocalizations.of(context)!.settingsAbout,
              Icons.question_answer,
              () {
                Navigator.of(context).popAndPushNamed(AboutScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
