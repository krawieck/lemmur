// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_account_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ManageAccountStore on ManageAccountStoreBase, Store {
  final _$localUserSettingsViewAtom =
      Atom(name: 'ManageAccountStoreBase.localUserSettingsView');

  @override
  AsyncValue<LocalUserSettingsView> get localUserSettingsView {
    _$localUserSettingsViewAtom.reportRead();
    return super.localUserSettingsView;
  }

  @override
  set localUserSettingsView(AsyncValue<LocalUserSettingsView> value) {
    _$localUserSettingsViewAtom.reportWrite(value, super.localUserSettingsView,
        () {
      super.localUserSettingsView = value;
    });
  }

  final _$savingAtom = Atom(name: 'ManageAccountStoreBase.saving');

  @override
  bool get saving {
    _$savingAtom.reportRead();
    return super.saving;
  }

  @override
  set saving(bool value) {
    _$savingAtom.reportWrite(value, super.saving, () {
      super.saving = value;
    });
  }

  final _$deletingAtom = Atom(name: 'ManageAccountStoreBase.deleting');

  @override
  bool get deleting {
    _$deletingAtom.reportRead();
    return super.deleting;
  }

  @override
  set deleting(bool value) {
    _$deletingAtom.reportWrite(value, super.deleting, () {
      super.deleting = value;
    });
  }

  final _$showAvatarsAtom = Atom(name: 'ManageAccountStoreBase.showAvatars');

  @override
  bool get showAvatars {
    _$showAvatarsAtom.reportRead();
    return super.showAvatars;
  }

  @override
  set showAvatars(bool value) {
    _$showAvatarsAtom.reportWrite(value, super.showAvatars, () {
      super.showAvatars = value;
    });
  }

  final _$showNsfwAtom = Atom(name: 'ManageAccountStoreBase.showNsfw');

  @override
  bool get showNsfw {
    _$showNsfwAtom.reportRead();
    return super.showNsfw;
  }

  @override
  set showNsfw(bool value) {
    _$showNsfwAtom.reportWrite(value, super.showNsfw, () {
      super.showNsfw = value;
    });
  }

  final _$sendNotificationsToEmailAtom =
      Atom(name: 'ManageAccountStoreBase.sendNotificationsToEmail');

  @override
  bool get sendNotificationsToEmail {
    _$sendNotificationsToEmailAtom.reportRead();
    return super.sendNotificationsToEmail;
  }

  @override
  set sendNotificationsToEmail(bool value) {
    _$sendNotificationsToEmailAtom
        .reportWrite(value, super.sendNotificationsToEmail, () {
      super.sendNotificationsToEmail = value;
    });
  }

  final _$defaultListingTypeAtom =
      Atom(name: 'ManageAccountStoreBase.defaultListingType');

  @override
  PostListingType get defaultListingType {
    _$defaultListingTypeAtom.reportRead();
    return super.defaultListingType;
  }

  @override
  set defaultListingType(PostListingType value) {
    _$defaultListingTypeAtom.reportWrite(value, super.defaultListingType, () {
      super.defaultListingType = value;
    });
  }

  final _$defaultSortTypeAtom =
      Atom(name: 'ManageAccountStoreBase.defaultSortType');

  @override
  SortType get defaultSortType {
    _$defaultSortTypeAtom.reportRead();
    return super.defaultSortType;
  }

  @override
  set defaultSortType(SortType value) {
    _$defaultSortTypeAtom.reportWrite(value, super.defaultSortType, () {
      super.defaultSortType = value;
    });
  }

  final _$initialAvatarAtom =
      Atom(name: 'ManageAccountStoreBase.initialAvatar');

  @override
  String? get initialAvatar {
    _$initialAvatarAtom.reportRead();
    return super.initialAvatar;
  }

  @override
  set initialAvatar(String? value) {
    _$initialAvatarAtom.reportWrite(value, super.initialAvatar, () {
      super.initialAvatar = value;
    });
  }

  final _$initialBannerAtom =
      Atom(name: 'ManageAccountStoreBase.initialBanner');

  @override
  String? get initialBanner {
    _$initialBannerAtom.reportRead();
    return super.initialBanner;
  }

  @override
  set initialBanner(String? value) {
    _$initialBannerAtom.reportWrite(value, super.initialBanner, () {
      super.initialBanner = value;
    });
  }

  final _$newAvatarAtom = Atom(name: 'ManageAccountStoreBase.newAvatar');

  @override
  String? get newAvatar {
    _$newAvatarAtom.reportRead();
    return super.newAvatar;
  }

  @override
  set newAvatar(String? value) {
    _$newAvatarAtom.reportWrite(value, super.newAvatar, () {
      super.newAvatar = value;
    });
  }

  final _$newBannerAtom = Atom(name: 'ManageAccountStoreBase.newBanner');

  @override
  String? get newBanner {
    _$newBannerAtom.reportRead();
    return super.newBanner;
  }

  @override
  set newBanner(String? value) {
    _$newBannerAtom.reportWrite(value, super.newBanner, () {
      super.newBanner = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('ManageAccountStoreBase.fetch');

  @override
  Future<void> fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$saveSettingsAsyncAction =
      AsyncAction('ManageAccountStoreBase.saveSettings');

  @override
  Future<void> saveSettings() {
    return _$saveSettingsAsyncAction.run(() => super.saveSettings());
  }

  final _$deleteAccountAsyncAction =
      AsyncAction('ManageAccountStoreBase.deleteAccount');

  @override
  Future<void> deleteAccount() {
    return _$deleteAccountAsyncAction.run(() => super.deleteAccount());
  }

  @override
  String toString() {
    return '''
localUserSettingsView: ${localUserSettingsView},
saving: ${saving},
deleting: ${deleting},
showAvatars: ${showAvatars},
showNsfw: ${showNsfw},
sendNotificationsToEmail: ${sendNotificationsToEmail},
defaultListingType: ${defaultListingType},
defaultSortType: ${defaultSortType},
initialAvatar: ${initialAvatar},
initialBanner: ${initialBanner},
newAvatar: ${newAvatar},
newBanner: ${newBanner}
    ''';
  }
}
