import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/ui/colors.dart';

const String urlPattern = 'https?://\\S+';
const String emailPattern = r'\S+@\S+';
const String phonePattern = r'[\d-]{9,}';

class TextMessage extends StatelessWidget {
  final String body;
  final TextStyle style;
  final TextStyle? linkStyle;
  final Widget time;
  final Widget? status;

  const TextMessage({
    super.key,
    required this.body,
    required this.style,
    required this.time,
    this.linkStyle,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text.rich(TextSpan(children: linkify(body)), style: style),
        time,
        if (status != null) status!,
      ],
    );
  }

  WidgetSpan buildLinkComponent(String text, String linkToOpen) => WidgetSpan(
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: lightMallow,
            borderRadius: BorderRadius.circular(6.0),
            child: Text(
              text,
              style: linkStyle,
            ),
            onTap: () => openUrl(Uri.parse(linkToOpen)),
          )));

  List<InlineSpan> linkify(String text) {
    final List<InlineSpan> list = <InlineSpan>[];
    final RegExp linkRegExp =
        RegExp('($urlPattern)|($emailPattern)|($phonePattern)');
    final RegExpMatch? match = linkRegExp.firstMatch(text);

    if (match == null) {
      list.add(TextSpan(text: text));
      return list;
    }

    if (match.start > 0) {
      list.add(TextSpan(text: text.substring(0, match.start)));
    }

    final String linkText = match.group(0)!;
    if (linkText.contains(RegExp(urlPattern))) {
      list.add(buildLinkComponent(linkText, linkText));
    } else if (linkText.contains(RegExp(emailPattern))) {
      list.add(buildLinkComponent(linkText, 'mailto:$linkText'));
    } else if (linkText.contains(RegExp(phonePattern))) {
      list.add(buildLinkComponent(linkText, 'tel:$linkText'));
    } else {
      throw 'Unexpected match: $linkText';
    }
    list.addAll(linkify(text.substring(match.start + linkText.length)));

    return list;
  }

  Future<void> openUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
