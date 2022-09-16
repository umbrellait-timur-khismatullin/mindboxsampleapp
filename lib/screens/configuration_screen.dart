import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mindbox/mindbox.dart';
import 'package:mindbox_sample_app/widgets/text_container.dart';
import 'sdk_test_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool shouldCreateCustomer = true;
  bool subscribeIfCreated = false;
  TextEditingController domainController = TextEditingController();
  TextEditingController endpointController = TextEditingController();
  TextEditingController deviceUUIDController = TextEditingController();
  TextEditingController installationIDController = TextEditingController();
  String url = '';
  String payload = '';
  String operationResult = '';

  @override
  void initState() {
    Mindbox.instance.onPushClickReceived(setDataFromPush());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        elevation: 0.5,
        title:
            const Text('Configuration', style: TextStyle(color: Colors.black)),
        actions: [
          buildAppBarButton('clear', () => clear()),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              buildTextField(hint: 'Domain', controller: domainController),
              buildTextField(hint: 'Endpoint', controller: endpointController),
              buildTextField(
                  hint: 'Device UUID', controller: deviceUUIDController),
              buildTextField(
                  hint: 'Installation ID',
                  controller: installationIDController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Should create customer'),
                  Switch(
                      value: shouldCreateCustomer,
                      onChanged: (value) {
                        setState(() {
                          shouldCreateCustomer = value;
                        });
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subscribe customer if created'),
                  Switch(
                      value: subscribeIfCreated,
                      onChanged: (value) {
                        setState(() {
                          subscribeIfCreated = value;
                        });
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: TextButton(
                    onPressed: () => initialize(),
                    child: const Text('Initialize',
                        style: TextStyle(fontSize: 30))),
              ),
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
              if (operationResult.isNotEmpty)
                TextContainer(
                  field: 'Operation result',
                  value: operationResult,
                ),
            ],
          ),
        ),
      ),
    );
  }

  clear() {
    domainController.clear();
    endpointController.clear();
    deviceUUIDController.clear();
    installationIDController.clear();
  }

  Widget buildTextField(
      {required String hint, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hint,
          labelText: hint,
        ),
      ),
    );
  }

  Widget buildAppBarButton(String text, Function() callback) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: callback,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void initialize() async {
    try {
      final config = Configuration(
        domain: domainController.text,
        endpointIos: endpointController.text,
        endpointAndroid: endpointController.text,
        previousDeviceUUID: deviceUUIDController.text,
        previousInstallationId: installationIDController.text,
        shouldCreateCustomer: shouldCreateCustomer,
        subscribeCustomerIfCreated: subscribeIfCreated,
      );
      clear();
      Mindbox.instance.init(configuration: config);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SdkTestScreen(configuration: config)));
    } on Exception catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Function(String, String) setDataFromPush() {
    return (link, payloadData) {
      setState(() {
        url = link;
        payload = payloadData;
      });
    };
  }
}
