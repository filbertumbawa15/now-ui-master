import 'package:flutter/material.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/widgets/navbar.dart';
import 'package:now_ui_flutter/widgets/table-cell.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool switchValueOne;
  bool switchValueTwo;

  void initState() {
    setState(() {
      switchValueOne = true;
      switchValueTwo = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: Row(
            children: <Widget>[
              Image.asset(
                'assets/imgs/taslogo.png',
                height: 30.0,
                width: 30.0,
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Color(0xFF01a6ff),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imgs/bgapps2.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 75.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text("Payment Settings",
                        style: TextStyle(
                            color: NowUIColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("These are also important settings",
                        style: TextStyle(color: NowUIColors.time)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Use FaceID to signin",
                        style: TextStyle(color: NowUIColors.text)),
                    Switch.adaptive(
                      value: switchValueOne,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueOne = newValue),
                      activeColor: NowUIColors.primary,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Auto-Lock security",
                        style: TextStyle(color: NowUIColors.text)),
                    Switch.adaptive(
                      value: switchValueTwo,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueTwo = newValue),
                      activeColor: NowUIColors.primary,
                    )
                  ],
                ),
                TableCellSettings(
                    title: "Notifications",
                    onTap: () {
                      Navigator.pushNamed(context, '/pro');
                    }),
                SizedBox(height: 36.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text("Payment Settings",
                        style: TextStyle(
                            color: NowUIColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("These are also important settings",
                        style: TextStyle(color: NowUIColors.time)),
                  ),
                ),
                TableCellSettings(title: "Manage Payment Options"),
                TableCellSettings(title: "Manage Gift Cards"),
                SizedBox(
                  height: 36.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
