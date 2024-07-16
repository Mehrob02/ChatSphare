// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/settings/settings_service.dart';

class CustomisationPage extends StatefulWidget {
  const CustomisationPage({super.key});

  @override
  State<CustomisationPage> createState() => _CustomisationPageState();
}

class _CustomisationPageState extends State<CustomisationPage> {
  List<MaterialColor> appColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
  ];
List <Color> walpaperColors = [
Colors.red,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.yellow,
    Colors.deepOrange,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
];
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: const Text(
            'Change App Theme',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    settingsService.colorChange(true);
                  },
                  child: Text("Try yourself"),
                ),
                Column(
                  children: [
                    Text("Choose the wallpaper"),
                    SizedBox(
                      height: 600, // Adjust the height based on your requirement
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              settingsService.changeWallpaper(index);
                              debugPrint(settingsService.wallpaperPath+index.toString());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.asset(kIsWeb?"wallpapers/wallpaper-${index+1}.jpeg":"assets/wallpapers/wallpaper-${index+1}.jpeg"),
                                 if(settingsService.wallpaperPath=="wallpapers/wallpaper-${index+1}.jpeg"||settingsService.wallpaperPath=="assets/wallpapers/wallpaper-${index+1}.jpeg") Positioned(
                                    top: 0,
                                    left: 0,
                                  child: Icon(Icons.done,color: Theme.of(context).colorScheme.primary,size: IconTheme.of(context).size!*1.5,))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(onPressed: (){settingsService.deleteWallpaper();}, child: Text("None"))
                  ],
                ),
                Column(
                  children: [
                    Text("Choose the background color"),
                    SizedBox(
                      height: 600, // Adjust the height based on your requirement
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                 Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: walpaperColors[index],
                                 )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(onPressed: (){settingsService.deleteWallpaper();}, child: Text("None"))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
