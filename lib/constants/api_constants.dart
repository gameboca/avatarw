class ApiConstants {
  static const String dropboxTokenUrl = 'https://api.dropbox.com/oauth2/token';
  static const String dropboxSharedLink =
      'https://www.dropbox.com/scl/fo/yamb9atkfqc3ul1u10j0j/AIr1M_W87RY_2tuRncmIiGQ?rlkey=03u0hwwonh1re8p1bn3v6vpm6&dl=0';
  static const String dropboxDownloadUrl =
      'https://content.dropboxapi.com/2/sharing/get_shared_link_file';

  // Reverse engineered OAuth credentials
  static const String clientId = '4fqhudlyl825rj5';
  static const String clientSecret = 'eiybsjjaithnlk5';
  static const String refreshToken =
      'VsGFqF04AmYAAAAAAAAAAdJQCmZ5rspUrfht2_Mykb5Mk6TsUfEn9_SbIX26RPj5';

  // Category remote folders
  static const String modsFolder = '/Mbw9nhd3r';
  static const String housesFolder = '/Hd8b29jr9e';
  static const String editorFolder = '/Eh289h9foe';

  static const String modsContentJson = '$modsFolder/content.json';
  static const String housesContentJson = '$housesFolder/content.json';
  static const String editorContentJson = '$editorFolder/content.json';
}
