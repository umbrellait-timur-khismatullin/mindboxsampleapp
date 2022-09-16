import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindbox/mindbox.dart';
import 'package:mindbox_sample_app/widgets/text_container.dart';

class SdkTestScreen extends StatefulWidget {
  const SdkTestScreen({Key? key, required this.configuration})
      : super(key: key);
  final Configuration configuration;

  @override
  SdkTestScreenState createState() => SdkTestScreenState();
}

class SdkTestScreenState extends State<SdkTestScreen> {
  String _deviceUUID = '';
  String _token = '';
  bool _loading = false;
  String url = '';
  String payload = '';

  @override
  void initState() {
    Mindbox.instance.onPushClickReceived(setPushData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        elevation: 0.5,
        title: FutureBuilder(
          future: Mindbox.instance.nativeSdkVersion,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return AutoSizeText(
                'Mindbox ${Platform.isIOS ? 'iOs' : 'Android'}'
                ' SDK ${snapshot.data}',
                maxLines: 1,
                style: const TextStyle(color: Colors.black),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Configuration parameters',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
              TextContainer(
                  field: 'Domain', value: widget.configuration.domain),
              TextContainer(
                  field: 'Endpoint',
                  value: widget.configuration.endpointAndroid),
              TextContainer(
                  field: 'Previous Device UUID',
                  value: widget.configuration.previousDeviceUUID.isEmpty
                      ? 'empty'
                      : widget.configuration.previousDeviceUUID),
              TextContainer(
                  field: 'Previous Installation ID',
                  value: widget.configuration.previousInstallationId.isEmpty
                      ? 'empty'
                      : widget.configuration.previousInstallationId),
              TextContainer(
                  field: 'Should create customer',
                  value: widget.configuration.shouldCreateCustomer.toString()),
              TextContainer(
                  field: 'Subscribe customer if created',
                  value: widget.configuration.subscribeCustomerIfCreated
                      .toString()),
              if (url.isNotEmpty)
                TextContainer(
                  field: 'Link',
                  value: url,
                ),
              if (payload.isNotEmpty)
                TextContainer(
                  field: 'Payload',
                  value: payload,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Mindbox.instance.getDeviceUUID((uuid) {
                        setState(() {
                          _deviceUUID = uuid;
                        });
                      });
                    },
                    child: const Text(
                      'get device uuid',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_deviceUUID.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _deviceUUID))
                            .then((value) {
                          const snackBar = SnackBar(content: Text('Copied'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      },
                    )
                ],
              ),
              if (_deviceUUID.isNotEmpty)
                TextContainer(field: 'Device UUID', value: _deviceUUID),
              TextButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  Mindbox.instance.getToken((token) {
                    setState(() {
                      _token = token;
                      _loading = false;
                    });
                  });
                },
                child: const Text(
                  'get token',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              if (_token.isNotEmpty)
                TextContainer(
                    field: '${Platform.isIOS ? 'APNS' : 'FMS'} token',
                    value: _token),
              if (_loading) const CircularProgressIndicator(),

            ],
          ),
        ),
      ),
    );
  }

  Function(String link, String payloadData) setPushData() {
    return (link, payloadData) {
      setState(() {
        url = link;
        payload = payloadData;
      });
    };
  }
}
