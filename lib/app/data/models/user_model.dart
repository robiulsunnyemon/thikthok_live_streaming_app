class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  double? coins;
  int? totalLike;
  String? phoneNumber;
  bool? isVerified;
  String? country;
  String? gender;
  String? dateOfBirth;
  String? bio;
  bool? isOnline;
  int? followingCount;
  int? followersCount;
  String? accountStatus;
  String? role;
  String? profileImage;
  String? authProvider;
  String? createdAt;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.coins,
    this.phoneNumber,
    this.isVerified,
    this.country,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.totalLike,
    this.isOnline,
    this.followingCount,
    this.followersCount,
    this.accountStatus,
    this.role,
    this.profileImage,
    this.authProvider,
    this.createdAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    coins = json['coins'];
    phoneNumber = json['phone_number'];
    isVerified = json['is_verified'];
    country = json['country'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    bio = json['bio'];
    isOnline = json['is_online'];
    followingCount = json['following_count'];
    followersCount = json['followers_count'];
    accountStatus = json['account_status'];
    role = json['role'];
    totalLike=json['total_like'];
    profileImage = json['profile_image'];
    authProvider = json['auth_provider'];
    createdAt = json['created_at'];
  }
  
  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}
