import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:mobx/mobx.dart';

import '../../stores/accounts_store.dart';
import '../../util/async_value.dart';

part 'manage_account_store.g.dart';

class ManageAccountStore = ManageAccountStoreBase with _$ManageAccountStore;

abstract class ManageAccountStoreBase with Store {
  @observable
  AsyncValue<LocalUserSettingsView> localUserSettingsView =
      const AsyncValue.loading();

  @observable
  bool saving = false;
  @observable
  bool deleting = false;

  @observable
  bool showAvatars = true;
  @observable
  bool showNsfw = false;
  @observable
  bool sendNotificationsToEmail = false;
  @observable
  PostListingType defaultListingType = PostListingType.all;
  @observable
  SortType defaultSortType = SortType.active;
  @observable
  String? initialAvatar;
  @observable
  String? initialBanner;
  @observable
  String? newAvatar;
  @observable
  String? newBanner;

  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  final matrixUserController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordVerifyController = TextEditingController();
  final oldPasswordController = TextEditingController();

  final deleteAccountPasswordController = TextEditingController();

  final AccountsStore _accountsStore;
  final String _instanceHost;
  final String _username;

  ManageAccountStoreBase({
    required AccountsStore accountsStore,
    required String instanceHost,
    required String username,
  })   : _accountsStore = accountsStore,
        _instanceHost = instanceHost,
        _username = username;

  @action
  Future<void> fetch() async {
    final future = LemmyApiV3(_instanceHost)
        .run(GetSite(
          auth: _accountsStore.userDataFor(_instanceHost, _username)!.jwt.raw,
        ))
        .then((value) => value.myUser!);

    await for (final val in AsyncValue.fromFuture(future)) {
      localUserSettingsView = val;

      if (val.state == AsyncValueState.data) {
        final data = val.requireData;

        displayNameController.text = data.person.preferredUsername ?? '';
        bioController.text = data.person.bio ?? '';
        emailController.text = data.localUser.email ?? '';
        matrixUserController.text = data.person.matrixUserId ?? '';
        initialAvatar = data.person.avatar;
        initialBanner = data.person.banner;

        showAvatars = data.localUser.showAvatars;
        showNsfw = data.localUser.showNsfw;
        sendNotificationsToEmail = data.localUser.sendNotificationsToEmail;
        defaultSortType = data.localUser.defaultSortType;
        defaultListingType = data.localUser.defaultListingType;
      }
    }
  }

  @action
  Future<void> saveSettings() async {
    final user = localUserSettingsView.requireData;
    final updatedAvatar = newAvatar ?? initialAvatar;
    final updatedBanner = newBanner ?? initialBanner;

    try {
      saving = true;
      await LemmyApiV3(_instanceHost).run(SaveUserSettings(
        auth: _accountsStore.userDataFor(_instanceHost, _username)!.jwt.raw,
        showNsfw: showNsfw,
        theme: user.localUser.theme,
        defaultSortType: defaultSortType,
        defaultListingType: defaultListingType,
        lang: user.localUser.lang,
        showAvatars: showAvatars,
        sendNotificationsToEmail: sendNotificationsToEmail,
        avatar: updatedAvatar,
        banner: updatedBanner,
        newPassword: newPasswordController.text.isEmpty
            ? null
            : newPasswordController.text,
        newPasswordVerify: newPasswordVerifyController.text.isEmpty
            ? null
            : newPasswordVerifyController.text,
        oldPassword: oldPasswordController.text.isEmpty
            ? null
            : oldPasswordController.text,
        matrixUserId: matrixUserController.text.isEmpty
            ? null
            : matrixUserController.text,
        preferredUsername: displayNameController.text.isEmpty
            ? null
            : displayNameController.text,
        bio: bioController.text.isEmpty ? null : bioController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
      ));
    } finally {
      saving = false;
    }

    initialAvatar = updatedAvatar;
    initialBanner = updatedBanner;
    newAvatar = null;
    newBanner = null;
  }

  @action
  Future<void> deleteAccount() async {
    try {
      deleting = true;
      await LemmyApiV3(_instanceHost).run(DeleteAccount(
        password: deleteAccountPasswordController.text,
        auth: _accountsStore.userDataFor(_instanceHost, _username)!.jwt.raw,
      ));

      await _accountsStore.removeAccount(_instanceHost, _username);
    } finally {
      deleting = false;
    }
  }
}
