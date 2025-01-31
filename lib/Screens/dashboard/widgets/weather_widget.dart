// import 'package:flutter/material.dart';
// import 'dart:html' as html;
// import 'dart:ui' as ui;

// class WeatherWidget extends StatelessWidget {
//   const WeatherWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     const String viewType = 'weather-widget';

//     // Register the view factory only once
//     ui.platformViewRegistry.registerViewFactory(
//       viewType,
//       (int viewId) {
//         final html.DivElement container = html.DivElement();

//         final html.DivElement widgetDiv = html.DivElement()
//           ..classes.add('tomorrow')
//           ..setAttribute('data-location-id', '082582,083259,082891,083373,083924,082601')
//           ..setAttribute('data-language', 'EN')
//           ..setAttribute('data-unit-system', 'METRIC')
//           ..setAttribute('data-skin', 'dark')
//           ..setAttribute('data-widget-type', 'current6')
//           ..style.paddingBottom = '22px'
//           ..style.position = 'relative';

//         final html.AnchorElement link = html.AnchorElement()
//           ..href = 'https://www.tomorrow.io/weather-api/'
//           ..rel = 'nofollow noopener noreferrer'
//           ..target = '_blank'
//           ..style.position = 'absolute'
//           ..style.bottom = '0'
//           ..style.transform = 'translateX(-50%)'
//           ..style.left = '50%';

//         final html.ImageElement img = html.ImageElement()
//           ..alt = 'Powered by the Tomorrow.io Weather API'
//           ..src = 'https://weather-website-client.tomorrow.io/img/powered-by.svg'
//           ..width = 250
//           ..height = 18;

//         link.append(img);
//         widgetDiv.append(link);
//         container.append(widgetDiv);

//         _injectScript();

//         return container;
//       },
//     );

//     return SizedBox(
//       height: 400,
//       child: HtmlElementView(
//         viewType: viewType,
//       ),
//     );
//   }

//   void _injectScript() {
//     if (html.document.getElementById('tomorrow-sdk') == null) {
//       final html.ScriptElement script = html.ScriptElement()
//         ..id = 'tomorrow-sdk'
//         ..type = 'text/javascript'
//         ..src = 'https://www.tomorrow.io/v1/widget/sdk/sdk.bundle.min.js';

//       html.document.body!.append(script);
//     } else {
//       html.window.callMethod('__TOMORROW__.renderWidget', []);
//     }
//   }
// }
