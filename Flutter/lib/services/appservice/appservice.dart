class AppService {
  static const cloudUpdateHourLimit = 4;
  static const manualUpdateMinuteLimit = 10;
  static const backupUpdateHourLimit = 24;

  static Future getPackageInfo() async {
    //return await PackageInfo.fromPlatform();
  }

  static const String backupFilePrefix = 'webcards-backup-';

  static const String appIconMini =
      "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png";

  static const String privacyPolicyURL =
      "https://webcards.flycricket.io/privacy.html";
  static const String termsConditionsURL =
      "https://webcards.flycricket.io/terms.html";
}
