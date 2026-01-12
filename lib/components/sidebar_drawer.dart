import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      child: Center(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: 40),
                SvgPicture.asset("assets/images/flexai.svg", width: 100),
                Text(
                  "version 1.0.0",
                  style: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
                ),
                SizedBox(height: 10),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
