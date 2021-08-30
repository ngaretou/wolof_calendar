// @dart=2.9

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'months_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme.dart';
import '../providers/user_prefs.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding-screen';
  OnboardingScreen({Key key}) : super(key: key);

  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _totalPages = 3;
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 1);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                _currentPage = page;
                setState(() {});
              },
              children: <Widget>[
                _buildPageContent(
                    isShowImageOnTop: false,
                    bgimage: 'assets/images/1.jpg',
                    // image: null,
                    body: AppLocalizations.of(context).introPage1,
                    color: Color(0xFFFF7252)),
                _buildPageContent(
                    isShowImageOnTop: true,
                    bgimage: 'assets/images/2.jpg',
                    body: AppLocalizations.of(context).introPage2,
                    color: Color(0xFFFFA131)),
                _buildPageContent(
                    isShowImageOnTop: false,
                    bgimage: 'assets/images/3.jpg',
                    body: AppLocalizations.of(context).introPage3,
                    color: Color(0xFF3C60FF))
              ],
            ),
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width * .05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * .9,
                    child: Row(
                      children: [
                        Container(
                          child: Row(children: [
                            for (int i = 0; i < _totalPages; i++)
                              i == _currentPage
                                  ? _buildPageIndicator(true)
                                  : _buildPageIndicator(false)
                          ]),
                        ),
                        Spacer(),
                        languageChooser(),
                        Spacer(),
                        if (_currentPage != 2)
                          InkWell(
                            onTap: () {
                              _pageController.animateToPage(2,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.linear);
                              setState(() {});
                            },
                            child: Container(
                              height: Platform.isIOS ? 70 : 60,
                              alignment: Alignment.center,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        if (_currentPage == 2)
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .popAndPushNamed(MonthsScreen.routeName);
                            },
                            child: Container(
                              height: Platform.isIOS ? 70 : 60,
                              alignment: Alignment.center,
                              child: Text(
                                'Start',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget languageChooser() {
    int _value;
    bool/*!*/ firstRun =
        Provider.of<UserPrefs>(context, listen: false).showOnboarding;
    String/*!*/ chosenLang =
        Provider.of<ThemeModel>(context, listen: false).userLang;
    if (firstRun == true) {
      _value = 1;
    } else {
      switch (chosenLang) {
        case "wo":
          {
            _value = 1;
            break;
          }
        case "fr":
          {
            _value = 2;
            break;
          }
        case "en":
          {
            _value = 3;
            break;
          }
      }
    }

    TextStyle chooserStyle = TextStyle(color: Colors.black87);
    return Container(
      padding: EdgeInsets.only(left: 10),
      width: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white38,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            value: _value,
            items: [
              DropdownMenuItem(
                child: Text("Wolof", style: chooserStyle),
                value: 1,
              ),
              DropdownMenuItem(
                child: Text("Français", style: chooserStyle),
                value: 2,
              ),
              DropdownMenuItem(
                child: Text("English", style: chooserStyle),
                value: 3,
              ),
            ],
            onChanged: (value) {
              switch (value) {
                case 1:
                  {
                    setState(() {
                      Provider.of<ThemeModel>(context, listen: false)
                          .setLang('wo');
                      _value = value;
                    });
                    break;
                  }
                case 2:
                  {
                    setState(() {
                      Provider.of<ThemeModel>(context, listen: false)
                          .setLang('fr');
                      _value = value;
                    });
                    break;
                  }
                case 3:
                  {
                    setState(() {
                      Provider.of<ThemeModel>(context, listen: false)
                          .setLang('en');
                      _value = value;
                    });
                    break;
                  }
              }
            }),
      ),
    );
  }

  Widget _buildPageContent(
      {String bgimage,
      // String image,
      String body,
      Color color,
      isShowImageOnTop}) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(bgimage),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(.9),
                Colors.black.withOpacity(.3)
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!isShowImageOnTop)
                Column(
                  children: [
                    Center(
                        // child: Image.asset(image),
                        ),
                    SizedBox(height: 50),
                    Container(
                      child: Text(
                        body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            height: 1.6,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              if (isShowImageOnTop)
                Column(
                  children: [
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1.6,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    SizedBox(height: 50),
                    Center(
                        // child: Image.asset(image),
                        ),
                  ],
                )
            ],
          ),
        ));
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      height: isCurrentPage ? 18.0 : 10.0,
      width: isCurrentPage ? 18.0 : 10.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
