import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkTheme = value;
    });
    // Add logic to save the theme preference
  }

  void _updateUserInfo() {
    // Add logic to update user information
  }

  void _logout() {
    // Add logic to log out the user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Recipes",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      body: ListView(
        children: [
          ListTile(
            title: Text('Dark Theme'),
            trailing: Switch(
              value: _isDarkTheme,
              onChanged: _toggleTheme,
            ),
          ),
          ListTile(
            title: Text('Update User Information'),
            trailing: Icon(Icons.arrow_forward),
            onTap: _updateUserInfo,
          ),
          ListTile(
            title: Text('Logout'),
            trailing: Icon(Icons.logout),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
