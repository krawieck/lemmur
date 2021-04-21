import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../hooks/stores.dart';
import '../l10n/l10n.dart';
import '../util/goto.dart';
import '../widgets/about_tile.dart';
import '../widgets/bottom_modal.dart';
import '../widgets/radio_picker.dart';
import 'add_account.dart';
import 'add_instance.dart';
import 'manage_account/manage_account.dart';

/// Page with a list of different settings sections
class SettingsPage extends StatelessWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context)!.settings),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Accounts'),
              onTap: () {
                goTo(context, (_) => AccountsConfigPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Appearance'),
              onTap: () {
                goTo(context, (_) => const AppearanceConfigPage());
              },
            ),
            const AboutTile()
          ],
        ),
      );
}

/// Settings for theme color, AMOLED switch
class AppearanceConfigPage extends HookWidget {
  const AppearanceConfigPage();

  @override
  Widget build(BuildContext context) {
    final configStore = useConfigStore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          const _SectionHeading('Theme'),
          for (final theme in ThemeMode.values)
            RadioListTile<ThemeMode>(
              value: theme,
              title: Text(describeEnum(theme)),
              groupValue: configStore.theme,
              onChanged: (selected) {
                if (selected != null) configStore.theme = selected;
              },
            ),
          SwitchListTile(
            title: const Text('AMOLED dark mode'),
            value: configStore.amoledDarkMode,
            onChanged: (checked) {
              configStore.amoledDarkMode = checked;
            },
          ),
          const SizedBox(height: 12),
          const _SectionHeading('General'),
          ListTile(
            title: Text(L10n.of(context)!.language),
            trailing: SizedBox(
              width: 120,
              child: RadioPicker<Locale>(
                title: 'Choose language',
                groupValue: configStore.locale,
                values: L10n.supportedLocales,
                mapValueToString: (locale) => locale.languageName,
                onChanged: (selected) {
                  configStore.locale = selected;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings for managing accounts
class AccountsConfigPage extends HookWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsStore = useAccountsStore();

    removeInstanceDialog(String instanceHost) async {
      if (await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove instance?'),
              content: Text('Are you sure you want to remove $instanceHost?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(L10n.of(context)!.no),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(L10n.of(context)!.yes),
                ),
              ],
            ),
          ) ??
          false) {
        await accountsStore.removeInstance(instanceHost);
        Navigator.of(context).pop();
      }
    }

    Future<void> removeUserDialog(String instanceHost, String username) async {
      if (await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove user?'),
              content: Text(
                  'Are you sure you want to remove $username@$instanceHost?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(L10n.of(context)!.no),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(L10n.of(context)!.yes),
                ),
              ],
            ),
          ) ??
          false) {
        await accountsStore.removeAccount(instanceHost, username);
        Navigator.of(context).pop();
      }
    }

    void accountActions(String instanceHost, String username) {
      showBottomModal(
        context: context,
        builder: (context) => Column(
          children: [
            if (accountsStore.defaultUsernameFor(instanceHost) != username)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Set as default'),
                onTap: () {
                  accountsStore.setDefaultAccountFor(instanceHost, username);
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove account'),
              onTap: () => removeUserDialog(instanceHost, username),
            ),
          ],
        ),
      );
    }

    void instanceActions(String instanceHost) {
      showBottomModal(
        context: context,
        builder: (context) => Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove instance'),
              onTap: () => removeInstanceDialog(instanceHost),
            ),
          ],
        ),
      );
    }

    // TODO: speeddial v3 has really stupid defaults here https://github.com/darioielardi/flutter_speed_dial/issues/149
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close, // TODO: change to + => x
        curve: Curves.bounceIn,
        tooltip: 'Add account or instance',
        overlayColor: theme.canvasColor,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            label: 'Add account',
            labelBackgroundColor: theme.canvasColor,
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (_) =>
                    AddAccountPage(instanceHost: accountsStore.instances.last)),
          ),
          SpeedDialChild(
            child: const Icon(Icons.dns),
            labelBackgroundColor: theme.canvasColor,
            label: 'Add instance',
            onTap: () => showCupertinoModalPopup(
                context: context, builder: (_) => const AddInstancePage()),
          ),
        ],
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          if (accountsStore.instances.isEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: TextButton.icon(
                    onPressed: () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => const AddInstancePage(),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add instance'),
                  ),
                ),
              ],
            ),
          for (final instance in accountsStore.instances) ...[
            const SizedBox(height: 40),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              onLongPress: () => instanceActions(instance),
              title: _SectionHeading(instance),
            ),
            for (final username in accountsStore.usernamesFor(instance)) ...[
              ListTile(
                trailing: username == accountsStore.defaultUsernameFor(instance)
                    ? Icon(
                        Icons.check_circle_outline,
                        color: theme.accentColor,
                      )
                    : null,
                title: Text(username),
                onLongPress: () => accountActions(instance, username),
                onTap: () {
                  goTo(
                      context,
                      (_) => ManageAccountPage(
                            instanceHost: instance,
                            username: username,
                          ));
                },
              ),
            ],
            if (accountsStore.usernamesFor(instance).isEmpty)
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add account'),
                onTap: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) => AddAccountPage(instanceHost: instance));
                },
              ),
          ]
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(text.toUpperCase(),
          style: theme.textTheme.subtitle2?.copyWith(color: theme.accentColor)),
    );
  }
}
