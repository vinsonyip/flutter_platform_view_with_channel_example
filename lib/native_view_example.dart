import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
class NativeViewExample extends StatefulWidget {
  final int counting;
  const NativeViewExample({Key? key, required this.counting}) : super(key: key);

  @override
  State<NativeViewExample> createState() => _NativeViewExampleState();
}

class _NativeViewExampleState extends State<NativeViewExample> {
  static const String _channel = 'increment';
  static const String _pong = 'pong';
  static const String _emptyMessage = '';
  static const BasicMessageChannel<String?> platform = BasicMessageChannel<String?>(_channel, StringCodec());

  @override
  Widget build(BuildContext context) {
    print(widget.counting);
    // This is used in the platform side to register the view.
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    Map<String, dynamic> creationParams = <String, dynamic>{'counting': widget.counting};


    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}


class NativeVirtualViewExample extends StatefulWidget {
  final int counting;
  final BasicMessageChannel<String?> platform;
  const NativeVirtualViewExample({Key? key, required this.platform, required this.counting}) : super(key: key);

  @override
  State<NativeVirtualViewExample> createState() => _NativeVirtualViewExampleState();
}

class _NativeVirtualViewExampleState extends State<NativeVirtualViewExample> {

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.

    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{'counting': widget.counting};

    return AndroidView(
      onPlatformViewCreated: (id) async{
      widget.platform..send("Basic_Channel")..setMessageHandler((message) async {
        if (message == 'basic_text_click') {
          print('Basic Text FlutterToast!');
        }
        print('===${message.toString()}==');
        return null;
        });
      },
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

