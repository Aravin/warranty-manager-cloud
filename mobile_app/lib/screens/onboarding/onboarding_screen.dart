import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warranty_manager_cloud/screens/auth/auth_widget.dart';
import 'package:warranty_manager_cloud/shared/constants.dart';
import 'package:warranty_manager_cloud/shared/loader.dart';
import 'package:warranty_manager_cloud/shared/locales.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final formKey = GlobalKey<FormBuilderState>();
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(BuildContext context) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      try {
        await EasyLoading.show(
          indicator: appLoader,
        );
        final formData = formKey.currentState?.value;
        final prefs = await SharedPreferences.getInstance();

        final String locale = formData!['locale'] ?? 'en_GB';

        await prefs.setString('locale', locale);
        await prefs.setBool('allow_expiry_notification',
            formData['allow_expiry_notification'] ?? true);
        await prefs.setBool('allow_remainder_notification',
            formData['allow_remainder_notification'] ?? true);

        await context.setLocale(locale.toLocale());
        await prefs.setBool('isFirstLaunch', false);

        Fluttertoast.showToast(
          msg: 'toast.settings_save_success'.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      } catch (err) {
        // debugPrint(err.toString());
        Fluttertoast.showToast(
          msg: 'toast.settings_save_failure'.tr(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      } finally {
        await EasyLoading.dismiss();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWidget()));
      }
    } else {
      debugPrint(formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return FormBuilder(
      key: formKey,
      child: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        // allowImplicitScrolling: true,
        // autoScrollDuration: 30000,
        // globalHeader: Align(
        //   alignment: Alignment.topRight,
        //   child: SafeArea(
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 16, right: 16),
        //       child: _buildImage('logo.png', 100),
        //     ),
        //   ),
        // ),
        globalFooter: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            child: const Text(
              'Let\'s go right away!',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _onIntroEnd(context),
          ),
        ),
        pages: [
          PageViewModel(
            title: "Language",
            body: "Choose your language you are going to use this application.",
            image: _buildImage('undraw_lang.png'),
            footer: Container(
              margin: kAppPaddingLarge,
              child: FormBuilderDropdown<String>(
                name: 'locale',
                initialValue: context.locale.toString() == 'en'
                    ? 'en_GB'
                    : context.locale.toString(),
                items: supportedLocales
                    .map((locale) => DropdownMenuItem(
                          value: '${locale.languageCode}_${locale.countryCode}',
                          child: Text(
                            localeLanguageMap[
                                '${locale.languageCode}_${locale.countryCode}']!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ))
                    .toList(),
              ),
            ),
            decoration: pageDecoration.copyWith(
              bodyFlex: 5,
              imageFlex: 5,
              footerFlex: 2,
              safeArea: 80,
            ),
          ),
          PageViewModel(
            title: "Notifications",
            body:
                "Allow Push Notification to remind 30 days before product/service expiry",
            image: _buildImage('undraw_notify.png'),
            footer: Container(
              margin: kAppPaddingSmall,
              child: FormBuilderCheckbox(
                name: 'allow_expiry_notification',
                initialValue: true,
                title: const Text('expiry_warranty_notification').tr(),
              ),
            ),
            decoration: pageDecoration.copyWith(
              bodyFlex: 5,
              imageFlex: 5,
              footerFlex: 2,
              safeArea: 80,
            ),
          ),
          PageViewModel(
            title: "Push Messages",
            body:
                "Allow Push Notification to remind to store new products/services",
            image: _buildImage('undraw_push_notifications.png'),
            footer: Container(
              margin: kAppPaddingSmall,
              child: FormBuilderCheckbox(
                name: 'allow_remainder_notification',
                initialValue: true,
                title: const Text('remainder_to_story_notification').tr(),
              ),
            ),
            decoration: pageDecoration.copyWith(
              bodyFlex: 5,
              imageFlex: 5,
              footerFlex: 2,
              safeArea: 80,
            ),
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: false,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: true,
        //rtl: true, // Display as right-to-left
        back: const Icon(Icons.arrow_back),
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          // color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          // color: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
