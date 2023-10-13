import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AzureAD OAuth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AzureAD OAuth'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Config config = Config(
      tenant: '1240183b-0ccd-447e-a3a1-a4721cf4ea49',
      clientId: '024dbb9f-52d5-4d2c-8b94-08f9bc4c1d7a',
      scope: 'api://024dbb9f-52d5-4d2c-8b94-08f9bc4c1d7a/Files.read',
      navigatorKey: navigatorKey,
      redirectUri:
          'https://login.microsoftonline.com/common/oauth2/nativeclient',
      loader: SizedBox());
  final AadOAuth oauth = AadOAuth(config);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Text(
                'Microsoft Azure AD authentication',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Container(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
              child: ElevatedButton.icon(
                label: Text('Login${kIsWeb ? ' (web popup)' : ''}'),
                icon: Icon(Icons.login_rounded),
                onPressed: () {
                  login(false);
                },
              ),
            ),
          ),



          Container(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
              child: ElevatedButton.icon(
                label: Text('Logout'),
                icon: Icon(Icons.logout_rounded),
                onPressed: () {
                  logout();
                },
              ),
            ),
          ),


        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(bool redirect) async {
    config.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
          (l) => showError(l.toString()),
          (r) => showMessage('Logged in successfully, your access token: $r'),
    );
    var accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(accessToken)));
    }
  }

  void hasCachedAccountInformation() async {
    var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('HasCachedAccountInformation: $hasCachedAccountInformation'),
      ),
    );
  }

  void logout() async {
    await oauth.logout();
    showMessage('Logged out');
  }
}
