import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wolof_calendar/l10n/app_localizations.dart';
import 'package:wolof_calendar/widgets/glass_app_bar.dart';

import 'qr_share.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

class OverflowMenu extends StatelessWidget {
  final bool isPhone;
  final VoidCallback? onOpenSettings;

  const OverflowMenu({super.key, required this.isPhone, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return isPhone
        ? GlassScaffold(
            isPhone: isPhone,
            child: OverflowMenuContents(onOpenSettings: onOpenSettings),
          )
        : OverflowMenuContents(onOpenSettings: onOpenSettings);
  }
}

class OverflowMenuContents extends StatelessWidget {
  final VoidCallback? onOpenSettings;

  const OverflowMenuContents({super.key, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24;
    TextStyle whitetitleLarge = Theme.of(context).textTheme.titleLarge!;
    //Main template for all titles
    Widget menuItemTitle(String title, Widget icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 25),
                Text(title, style: whitetitleLarge),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      children: [
        menuItemTitle(
          AppLocalizations.of(context)!.settingsTitle,
          const Icon(Icons.settings, size: iconSize),
          () {
            if (onOpenSettings != null) {
              onOpenSettings!();
            } else {
              Navigator.of(context).pop();
              Navigator.push(context, transparentRoute(const SettingsScreen()));
            }
          },
        ),

        const Divider(thickness: 1),
        menuItemTitle(
          // 'Add holidays to\nGoogle Calendar TT',
          AppLocalizations.of(context)!.addHolidays,
          const Icon(Icons.calendar_today, size: iconSize),
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

        menuItemTitle(
          AppLocalizations.of(context)!.shareAppLink,
          const Icon(Icons.share, size: iconSize),
          () async {
            List<ShareAppData> shareAppData = [
              ShareAppData(
                label: 'https://sng.al/cal',
                shareApp: ShareApp.site,
                // socialIcon: '\uf3ab',
                icon: Icons.home,
                link: 'https://sng.al/cal',
              ),
              // ShareAppData(
              //     label: 'Google Play',
              //     shareApp: ShareApp.android,
              //     socialIcon: '\uf3ab',
              //     link:
              //         'https://play.google.com/store/apps/details?id=org.mbs.cal.wol'),
              // ShareAppData(
              //     label: 'iOS & macOS',
              //     shareApp: ShareApp.iOS,
              //     socialIcon: '\uf179',
              //     link:
              //         'https://apps.apple.com/app/arminaatu-wolof/id1532220355'),
              // ShareAppData(
              //     label: 'web',
              //     shareApp: ShareApp.web,
              //     socialIcon: '\uf268',
              //     link: 'https://cal.sng.al/'),
            ];

            Navigator.of(context).pop();
            showQrShare(
              context,
              shareAppData,
              'Arminaatu Wolof',
              appIcon: Image.asset('assets/icons/icon.png'),
            );
          },
        ),

        menuItemTitle(
          AppLocalizations.of(context)!.moreApps,
          const Icon(Icons.web_asset, size: iconSize),
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

        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        menuItemTitle(
          AppLocalizations.of(context)!.settingsContactUsEmail,
          const Icon(Icons.email, size: iconSize),
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

        menuItemTitle(
          AppLocalizations.of(context)!.contactWhatsApp,
          const FaIcon(FontAwesomeIcons.whatsapp, size: iconSize),
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
        menuItemTitle(
          AppLocalizations.of(context)!.contactFBMessenger,
          const FaIcon(FontAwesomeIcons.facebookMessenger, size: iconSize),
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

            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: launchMode);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
        const Divider(thickness: 2),
        menuItemTitle(
          AppLocalizations.of(context)!.settingsAbout,
          const Icon(Icons.question_answer, size: iconSize),
          () {
            Navigator.of(context).pop();
            showAbout(context);
          },
        ),
      ],
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
                        text: ' copyright © 2025 La MBS.',
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        text: 'Appli © 2026 Foundational LLC.',
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
                Navigator.push(context, transparentRoute(const AboutScreen()));
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
