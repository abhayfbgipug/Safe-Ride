//importing neccessary files and packages
import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({Key key}) : super(key: key);
  // Designing App Bar and Drawer
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: Text("Safe Ride App"),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    //Self made logo for the app --
                    "https://drive.google.com/uc?export=view&id=1vNZNf1f7MD5bkI_hA7OWx7ocBko8h274"),
              )),
          ListTile(
            leading: Icon(Icons.support),
            title: Text("Contact Us "),
            subtitle: Text("abhayg.5325@gmail.com"),
            hoverColor: Colors.black26,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
