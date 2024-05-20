// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/settings/settings_service.dart';

class ChangeAppThemePage extends StatefulWidget {
  const ChangeAppThemePage({super.key});

  @override
  State<ChangeAppThemePage> createState() => _ChangeAppThemePageState();
}

class _ChangeAppThemePageState extends State<ChangeAppThemePage> {
  List<MaterialColor> appColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
  ];

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading:  IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
                          ),
          title: const Text('Change App Theme', style: TextStyle(color: Colors.white),),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: appColors.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            settingsService.changeAppColor(appColors[index]);
                          });
                        },
                        child: Icon(
                                Icons.circle,
                                color: appColors[index],
                              ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(onPressed: (){Navigator.pop(context); settingsService.colorChange(true);}, child: Text("Try yourself"))
            ],
          ),
        ),
      ),
    );
  }
}
