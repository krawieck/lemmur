import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';

import '../../hooks/delayed_loading.dart';
import '../../hooks/image_picker.dart';
import '../../hooks/stores.dart';
import '../../l10n/l10n.dart';
import '../../util/pictrs.dart';
import '../../widgets/bottom_safe.dart';
import '../../widgets/radio_picker.dart';
import 'manage_account_store.dart';

/// Page for managing things like username, email, avatar etc
/// This page will assume the manage account is logged in and
/// its token is in AccountsStore
class ManageAccountPage extends HookWidget {
  final String instanceHost;
  final String username;

  const ManageAccountPage({required this.instanceHost, required this.username});

  @override
  Widget build(BuildContext context) {
    final accountsStore = useAccountsStore();
    final store = useMemoized(
      () => ManageAccountStore(
        accountsStore: accountsStore,
        instanceHost: instanceHost,
        username: username,
      )..fetch(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$username@$instanceHost'),
      ),
      body: Observer(
        builder: (context) => store.localUserSettingsView.map(
          data: (data) => _ManageAccount(user: data, store: store),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, st) =>
              Center(child: Text('Error: ${error.toString()}')),
        ),
      ),
    );
  }
}

class _ManageAccount extends HookWidget {
  const _ManageAccount({
    Key? key,
    required this.user,
    required this.store,
  }) : super(key: key);

  final LocalUserSettingsView user;
  final ManageAccountStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bioFocusNode = useFocusNode();
    final emailFocusNode = useFocusNode();
    final matrixUserFocusNode = useFocusNode();
    final newPasswordFocusNode = useFocusNode();
    final verifyPasswordFocusNode = useFocusNode();
    final oldPasswordFocusNode = useFocusNode();

    handleSubmit() async {
      try {
        await store.saveSettings();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User settings saved'),
        ));
      } on Exception catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
        ));
      }
    }

    deleteAccountDialog() async {
      final confirmDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                  '${L10n.of(context)!.delete_account} @${user.instanceHost}@${user.person.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(L10n.of(context)!.delete_account_confirm),
                  const SizedBox(height: 10),
                  TextField(
                    controller: store.deleteAccountPasswordController,
                    autofillHints: const [AutofillHints.password],
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration:
                        InputDecoration(hintText: L10n.of(context)!.password),
                  )
                ],
              ),
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
          false;

      if (confirmDelete) {
        try {
          await store.deleteAccount();

          Navigator.of(context).pop();
        } on Exception catch (err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
          ));
        }
      } else {
        store.deleteAccountPasswordController.clear();
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        Observer(
          builder: (context) => _ImagePicker(
            user: user,
            name: L10n.of(context)!.avatar,
            initialUrl: store.initialAvatar,
            newUrl: store.newAvatar,
            onChange: (value) => store.newAvatar = value,
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => _ImagePicker(
            user: user,
            name: L10n.of(context)!.banner,
            initialUrl: store.initialBanner,
            newUrl: store.newBanner,
            onChange: (value) => store.newBanner = value,
          ),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.display_name, style: theme.textTheme.headline6),
        TextField(
          controller: store.displayNameController,
          onSubmitted: (_) => bioFocusNode.requestFocus(),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.bio, style: theme.textTheme.headline6),
        TextField(
          controller: store.bioController,
          focusNode: bioFocusNode,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => emailFocusNode.requestFocus(),
          minLines: 4,
          maxLines: 10,
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.email, style: theme.textTheme.headline6),
        TextField(
          focusNode: emailFocusNode,
          controller: store.emailController,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => matrixUserFocusNode.requestFocus(),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.matrix_user, style: theme.textTheme.headline6),
        TextField(
          focusNode: matrixUserFocusNode,
          controller: store.matrixUserController,
          onSubmitted: (_) => newPasswordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.new_password, style: theme.textTheme.headline6),
        TextField(
          focusNode: newPasswordFocusNode,
          controller: store.newPasswordController,
          autofillHints: const [AutofillHints.newPassword],
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          onSubmitted: (_) => verifyPasswordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.verify_password,
            style: theme.textTheme.headline6),
        TextField(
          focusNode: verifyPasswordFocusNode,
          controller: store.newPasswordVerifyController,
          autofillHints: const [AutofillHints.newPassword],
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          onSubmitted: (_) => oldPasswordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 8),
        Text(L10n.of(context)!.old_password, style: theme.textTheme.headline6),
        TextField(
          focusNode: oldPasswordFocusNode,
          controller: store.oldPasswordController,
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.of(context)!.type),
                const Text(
                  'This has currently no effect on lemmur',
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
            Observer(
              builder: (context) => RadioPicker<PostListingType>(
                values: const [
                  PostListingType.all,
                  PostListingType.local,
                  PostListingType.subscribed,
                ],
                groupValue: store.defaultListingType,
                onChanged: (val) => store.defaultListingType = val,
                mapValueToString: (value) => value.value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.of(context)!.sort_type),
                const Text(
                  'This has currently no effect on lemmur',
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
            Observer(
              builder: (context) => RadioPicker<SortType>(
                values: SortType.values,
                groupValue: store.defaultSortType,
                onChanged: (val) => store.defaultSortType = val,
                mapValueToString: (value) => value.value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => CheckboxListTile(
            value: store.showAvatars,
            onChanged: (val) {
              if (val != null) store.showAvatars = val;
            },
            title: Text(L10n.of(context)!.show_avatars),
            subtitle: const Text('This has currently no effect on lemmur'),
            dense: true,
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => CheckboxListTile(
            value: store.showNsfw,
            onChanged: (val) {
              if (val != null) store.showNsfw = val;
            },
            title: Text(L10n.of(context)!.show_nsfw),
            subtitle: const Text('This has currently no effect on lemmur'),
            dense: true,
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => CheckboxListTile(
            value: store.sendNotificationsToEmail,
            onChanged: (val) {
              if (val != null) store.sendNotificationsToEmail = val;
            },
            title: Text(L10n.of(context)!.send_notifications_to_email),
            dense: true,
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => ElevatedButton(
            onPressed: store.saving ? null : handleSubmit,
            child: store.saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                : Text(L10n.of(context)!.save),
          ),
        ),
        const SizedBox(height: 8),
        Observer(
          builder: (context) => ElevatedButton(
            onPressed: store.deleting ? null : deleteAccountDialog,
            style: ElevatedButton.styleFrom(primary: Colors.red),
            child: store.deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                : Text(L10n.of(context)!.delete_account.toUpperCase()),
          ),
        ),
        const BottomSafe(),
      ],
    );
  }
}

/// Picker and cleanuper for local images uploaded to pictrs
class _ImagePicker extends HookWidget {
  final String name;
  final String? initialUrl;
  final String? newUrl;
  final LocalUserSettingsView user;
  final ValueChanged<String?>? onChange;

  const _ImagePicker({
    Key? key,
    required this.initialUrl,
    required this.newUrl,
    required this.name,
    required this.user,
    required this.onChange,
  }) : super(key: key);

  bool get isInitial => newUrl == null;
  String? get url => newUrl ?? initialUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pictrsDeleteToken = useState<PictrsUploadFile?>(null);

    final imagePicker = useImagePicker();
    final accountsStore = useAccountsStore();
    final delayedLoading = useDelayedLoading();

    uploadImage() async {
      try {
        final pic = await imagePicker.getImage(source: ImageSource.gallery);
        // pic is null when the picker was cancelled
        if (pic != null) {
          delayedLoading.start();

          final upload = await PictrsApi(user.instanceHost).upload(
            filePath: pic.path,
            auth: accountsStore
                .userDataFor(user.instanceHost, user.person.name)!
                .jwt
                .raw,
          );
          pictrsDeleteToken.value = upload.files[0];

          onChange?.call(
              pathToPictrs(user.instanceHost, pictrsDeleteToken.value!.file));
        }
      } on Exception {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')));
      }

      delayedLoading.cancel();
    }

    removePicture({
      required PictrsUploadFile pictrsToken,
    }) {
      PictrsApi(user.instanceHost).delete(pictrsToken).catchError((_) {});

      pictrsDeleteToken.value = null;
      onChange?.call(null);
    }

    useEffect(() {
      pictrsDeleteToken.value = null;
    }, [initialUrl]);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: theme.textTheme.headline6),
            if (isInitial)
              ElevatedButton(
                onPressed: delayedLoading.loading ? null : uploadImage,
                child: delayedLoading.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator())
                    : Row(
                        children: const [Text('upload'), Icon(Icons.publish)],
                      ),
              )
            else
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    removePicture(pictrsToken: pictrsDeleteToken.value!),
              )
          ],
        ),
        if (url != null)
          CachedNetworkImage(
            imageUrl: url!,
            errorWidget: (_, __, ___) => const Icon(Icons.error),
          ),
      ],
    );
  }
}
