import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/settings/settings_alertdialog.dart';
import 'package:tearmusic/ui/mobile/common/settings/settings_container.dart';
import 'package:tearmusic/ui/mobile/common/settings/settings_stats.dart';
import 'package:tearmusic/ui/mobile/common/settings/settings_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final avatar = context.select<UserProvider, String>((user) => user.avatar);
    final username = context.select<UserProvider, String>((user) => user.username);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 180.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Card(
                          elevation: 3.0,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 16.0, bottom: 8.0),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: SizedBox(
                                        width: 52.0,
                                        height: 52.0,
                                        child: avatar != "" ? Image.network(avatar) : null,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22.0),
                                            ),
                                            Text(
                                              "View your profile",
                                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.chevron_right),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                child: Row(
                                  children: [
                                    SettingsStatsItem(name: "Minute spent", value: "214"),
                                    SettingsStatsItem(name: "Likes received", value: "16"),
                                    SettingsStatsItem(name: "Followers", value: "7"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SettingsContainer(
                        name: "Playback",
                        items: [
                          SettingsSwitchTile(
                            name: "Gapless",
                            desc: "Remove gap between songs",
                            value: true,
                            onChanged: (v) {},
                          ),
                          SettingsSwitchTile(
                            name: "Allow Explicit Content",
                            desc: "Explicit content is labeled with 'E'",
                            value: false,
                            onChanged: (v) {},
                          ),
                          SettingsSwitchTile(
                            name: "Show unplayable songs",
                            desc: "Show songs that are unplayable",
                            value: false,
                            onChanged: (v) {},
                          ),
                          SettingsSwitchTile(
                            name: "Trim silence",
                            desc: "Remove silence from start and end",
                            value: false,
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      SettingsContainer(
                        name: "Social",
                        items: [
                          SettingsSwitchTile(
                            name: "Private session",
                            desc: "Start a private session to listen privately",
                            value: true,
                            onChanged: (v) {},
                          ),
                          SettingsSwitchTile(
                            name: "Listening Activity",
                            desc: "Show what I was listening",
                            value: true,
                            onChanged: (v) {},
                          ),
                          SettingsSwitchTile(
                            name: "Recently played artists",
                            desc: "Show my recently played artists on my profile",
                            value: true,
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      SettingsContainer(
                        name: "Audio Quality",
                        items: [
                          SettingsSwitchTile(
                            name: "Wifi streaming",
                            desc: "Stream on wifi",
                            value: true,
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: TextButton.icon(
                          icon: const Icon(Ionicons.log_out_outline),
                          label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0)),
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 242, 88, 88).withOpacity(.25)),
                            foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 242, 88, 88)),
                          ),
                          onPressed: () {
                            SettingsAlertDialog().showCustomDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
