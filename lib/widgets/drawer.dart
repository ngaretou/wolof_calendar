// ignore_for_file: sized_box_for_whitespace
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:wolof_calendar/l10n/app_localizations.dart';

import '../providers/user_prefs.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserPrefs userPrefs = Provider.of<UserPrefs>(
      context,
      listen: false,
    ).userPrefs;

    TextStyle whitetitleLarge = Theme.of(context).textTheme.titleLarge!;

    //Main template for all titles
    Widget drawerTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                icon.toString().startsWith("FontAwesomeIcons")
                    ? FaIcon(icon, size: 27)
                    : Icon(icon, size: 27),
                const SizedBox(width: 25),
                Text(title, style: whitetitleLarge),
              ],
            ),
          ),
        ),
      );
    }

    return Drawer(
      child: Container(
        width: size.width * .8,
        //The color of the Drawer
        // color: Colors.transparent,
        color: userPrefs.glassEffects!
            ? Theme.of(context).colorScheme.surface.withAlpha(51)
            : Theme.of(context).colorScheme.surface,

        child: ListView(
          children: [
            //Main title
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.calendar, size: 27),
                  const SizedBox(width: 25),
                  Text(
                    "Arminaatu wolof",
                    style: Theme.of(context).textTheme.headlineSmall!,
                  ),
                ],
              ),
            ),
            const Divider(thickness: 3),
            drawerTitle(
              AppLocalizations.of(context)!.settingsTitle,
              Icons.settings,
              () {
                Navigator.of(context).pop();
                // Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
                clearPage(Widget page) => PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, _) => page,
                );
                Navigator.push(context, clearPage(const SettingsScreen()));
              },
            ),

            const Divider(thickness: 1),
            drawerTitle(
              // 'Add holidays to\nGoogle Calendar TT',
              AppLocalizations.of(context)!.addHolidays,
              Icons.calendar_today,
              () async {
                late String url;

                String directAddURL =
                    'https://calendar.google.com/calendar/u/0/r?cid=5islvfeuls670m9ckvpop40ao4@group.calendar.google.com';

                if (kIsWeb) {
                  //Direct add
                  url = directAddURL;
                } else if (Platform.isIOS) {
                  //iCal format for iOS
                  url =
                      'https://calendar.google.com/calendar/ical/5islvfeuls670m9ckvpop40ao4%40group.calendar.google.com/public/basic.ics';
                } else {
                  //Direct add
                  //second time here but have to account for web not liking Platform.isOS
                  url = directAddURL;
                }

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),

            const Divider(thickness: 1),
            drawerTitle(
              AppLocalizations.of(context)!.shareAppLink,
              Icons.share,
              () async {
                Navigator.of(context).pop();
                if (!kIsWeb) {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'https://sng.al/cal',
                      sharePositionOrigin: Rect.fromLTWH(
                        0,
                        0,
                        size.width,
                        size.height * .33,
                      ),
                    ),
                  );
                } else {
                  const url =
                      "mailto:?subject=Arminaatu Wolof&body=Xoolal appli Arminaatu Wolof fii: https://sng.al/cal";

                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw 'Could not launch $url';
                  }
                }
              },
            ),
            const Divider(thickness: 1),
            drawerTitle(
              AppLocalizations.of(context)!.moreApps,
              Icons.web_asset,
              () async {
                const url = 'https://sng.al/app';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            //Contact Us section
            const Divider(thickness: 2),

            Container(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settingsContactUs,
                      style: whitetitleLarge,
                    ),
                  ],
                ),
              ),
            ),

            // drawerTitle(
            //     AppLocalizations.of(context).settingsContactUs, null, null),
            drawerTitle(
              AppLocalizations.of(context)!.settingsContactUsEmail,
              Icons.email,
              () async {
                const url = 'mailto:equipedevmbs@gmail.com';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
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
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            /* facebook messenger had two problems on mobile. 
            This fb-messenger is the key for mobile working correctly.
            plus 

            in AndroidManifest: 
            <manifest ...>
              <queries>
                <package android:name="com.facebook.orca" />
              </queries>
            </manifest> 

          and 

          in Info.plist
          <key>LSApplicationQueriesSchemes</key>
          <array>
              <string>fb-messenger</string>
          </array> 
            If Android, it takes about 10 seconds on my Pixel to load
            this can be due to cold start: 
            https://github.com/flutter/flutter/issues/139417

            
            
            */
            //if (kIsWeb)
            drawerTitle(
              AppLocalizations.of(context)!.contactFBMessenger,
              FontAwesomeIcons.facebookMessenger,
              () async {
                String url = '';

                if (kIsWeb) {
                  url = 'https://m.me/buleenragal';
                } else {
                  url = "fb-messenger://user-thread/112787400906941";
                }

                // const url = 'https://m.me/buleenragal';
                // const url = "https://m.me/112787400906941";
                // const url = "https://www.messenger.com/t/112787400906941";

                LaunchMode launchMode = LaunchMode.externalApplication;
                print(url);
                print(launchMode.toString());
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: launchMode);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            const Divider(thickness: 2),
            drawerTitle(
              AppLocalizations.of(context)!.settingsAbout,
              Icons.question_answer,
              () {
                Navigator.of(context).pop();
                showAbout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showAbout(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(packageInfo.appName),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Row(
                  children: [
                    Container(
                      // child: Image.asset('assets/icons/icon.png'),
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/icon.png"),
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            "Arminaatu wolof",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        text: 'Arminaatu Wolof',
                      ),
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        text: ' produit par la MEAO. ',
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        text: 'Kàddug Yàlla',
                      ),
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        text: ' copyright © 2024 La MBS. ',
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        text: 'Appli © 2024 Foundational LLC.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          actions: <Widget>[
            OutlinedButton(
              child: const Text('Copyrights'),
              onPressed: () {
                // Navigator.of(context).pushNamed(AboutScreen.routeName);
                clearPage(Widget page) => PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, _) => page,
                );
                Navigator.push(context, clearPage(const AboutScreen()));
              },
            ),
            OutlinedButton(
              child: const Text('Licenses'),
              onPressed: () {
                // Navigator.of(context).pop();
                showLicenses(
                  context,
                  appName: packageInfo.appName,
                  appVersion:
                      '${packageInfo.version} (${packageInfo.buildNumber})',
                );
              },
            ),
            OutlinedButton(
              child: Text(AppLocalizations.of(context)!.settingsOK),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void showLicenses(BuildContext context, {String? appName, String? appVersion}) {
  void showLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    // assert(context != null);
    // assert(useRootNavigator != null);
    Navigator.of(context, rootNavigator: useRootNavigator).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
        ),
      ),
    );
  }

  showLicensePage(
    context: context,
    applicationVersion: appVersion,
    applicationName: appName,
    useRootNavigator: true,
  );
}
