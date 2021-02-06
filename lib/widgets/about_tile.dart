import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info/package_info.dart';

import '../gen/assets.gen.dart';
import '../hooks/memo_future.dart';
import '../url_launcher.dart';
import 'bottom_modal.dart';

/// Title that opens a dialog with information about Lemmur.
/// Licenses, changelog, version etc.
class AboutTile extends HookWidget {
  const AboutTile();

  @override
  Widget build(BuildContext context) {
    final packageInfoSnap = useMemoFuture(
      () => PackageInfo.fromPlatform()
          .then((e) => e, onError: (_, __) => PackageInfo(version: '')),
    );
    final assetBundle = DefaultAssetBundle.of(context);
    final changelogSnap =
        useMemoFuture(() => assetBundle.loadString('CHANGELOG.md'));

    if (!packageInfoSnap.hasData || !changelogSnap.hasData) {
      return const SizedBox.shrink();
    }

    final packageInfo = packageInfoSnap.data;
    final changelog = changelogSnap.data;

    return AboutListTile(
      icon: const Icon(Icons.info),
      aboutBoxChildren: [
        TextButton.icon(
          icon: const Icon(Icons.subject),
          label: const Text('changelog'),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => BottomModal(
              child: MarkdownBody(data: changelog),
            ),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.code),
          label: const Text('source code'),
          onPressed: () => openInBrowser('https://github.com/krawieck/lemmur'),
        ),
        TextButton.icon(
          icon: const Icon(Icons.monetization_on),
          label: const Text('support development'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () =>
                          openInBrowser('https://patreon.com/lemmur'),
                      child: const Text('Patreon'),
                    ),
                    TextButton(
                      onPressed: () =>
                          openInBrowser('https://buymeacoff.ee/lemmur'),
                      child: const Text('Buy Me a Coffee'),
                    ),
                  ],
                ),
              ),
            );
          }, // TODO: link to some donation site
        ),
      ],
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Assets.appIcon.image(width: 54),
      ),
      applicationVersion: packageInfo.version,
    );
  }
}
