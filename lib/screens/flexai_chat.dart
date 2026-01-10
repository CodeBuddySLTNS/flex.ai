import 'package:flutter/material.dart';

class FlexAIChat extends StatefulWidget {
  const FlexAIChat({super.key});

  @override
  State<FlexAIChat> createState() => _FlexAIChatState();
}

class _FlexAIChatState extends State<FlexAIChat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(child: Column(children: [
          
        ],)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 2),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Text("data")),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: BoxBorder.all(),
                ),
                child: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
