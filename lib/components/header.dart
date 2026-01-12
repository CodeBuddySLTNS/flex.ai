import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset("assets/images/flexai.svg", width: 50),
          Row(
            children: [
              Text(
                "Owner:",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Text("MrHairy", style: TextStyle(fontFamily: "Poppins")),
              SizedBox(width: 6),
              SvgPicture.asset("assets/images/crown.svg", width: 15),
            ],
          ),
          IconButton(
            icon: Icon(Icons.menu, size: 30),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
