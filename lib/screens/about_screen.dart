import 'package:material_ui/material_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:wolof_calendar/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //This builds the html sections below
    Widget htmlSection(String url) {
      //This is where we grab the HTML from the asset folder
      Future<String?> fetchHtmlSection(String url) async {
        String htmlSection = await DefaultAssetBundle.of(
          context,
        ).loadString(url);
        return htmlSection;
      }

      return FutureBuilder(
        future: fetchHtmlSection(url),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            //this is actually where the business happens; HTML just takes the data and renders it
            : HtmlWidget(
                snapshot.data.toString(),
                onTapUrl: (url) async {
                  final result = await canLaunchUrl(Uri.parse(url))
                      ? await launchUrl(Uri.parse(url))
                      : throw 'Could not launch $url';
                  return result;
                },
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsAbout)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                const SizedBox(width: 20),
                Text(
                  'Arminaatu Wolof',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 20),
            htmlSection("assets/html/about.html"),
            const Divider(),
            Text(
              'Remerciements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            htmlSection("assets/html/thanks.html"),
          ],
        ),
      ),
    );
  }
}
