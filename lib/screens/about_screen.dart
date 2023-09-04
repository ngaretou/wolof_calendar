import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //This builds the html sections below
    Widget htmlSection(String url) {
      //This is where we grab the HTML from the asset folder
      Future<String?> fetchHtmlSection(String url) async {
        String htmlSection =
            await DefaultAssetBundle.of(context).loadString(url);
        return htmlSection;
      }

      return FutureBuilder(
        future: fetchHtmlSection(url),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            //this is actually where the business happens; HTML just takes the data and renders it
            : Html(
                data: snapshot.data.toString(),
                onLinkTap: (String? url, Map<String, String> attributes,
                    element) async {
                  if (url != null) {
                    await canLaunchUrl(Uri.parse(url))
                        ? await launchUrl(Uri.parse(url))
                        : throw 'Could not launch $url';
                  }
                }),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsAbout,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: ListView(
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
                const SizedBox(
                  width: 20,
                ),
                Text('Arminaatu Wolof',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            htmlSection("assets/html/about.html"),
            const Divider(),
            Text('Remerciements',
                style: Theme.of(context).textTheme.titleLarge),
            htmlSection("assets/html/thanks.html"),
          ],
        ),
      ),
    );
  }
}
