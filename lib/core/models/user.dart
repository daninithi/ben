import 'dart:convert';
import 'dart:developer';

class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;
  final Map<String, dynamic>? lastMessage;
  final int? unreadCounter;
  final String? fcmToken;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.imageUrl,
      this.fcmToken,
      this.lastMessage,
      this.unreadCounter
      });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'fcmToken': fcmToken, 
      'lastMessage': lastMessage,
      'unreadCounter': unreadCounter
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    log(map.toString());
    return UserModel(
      uid: map['uid'] != null ? map['uid'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      fcmToken: map['fcmToken'] != null ? map['fcmToken'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      lastMessage: map['lastMessage'] != null
          ? Map<String, dynamic>.from(
              map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCounter:
          map['unreadCounter'] != null ? map['unreadCounter'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    // return 'UserModel(uid: $uid, name: $name, email: $email, imageUrl: $imageUrl, lastMessage: $lastMessage, unreadCounter: $unreadCounter)';
    return 'UserModel(uid: $uid, name: $name, email: $email, imageUrl: $imageUrl, fcmToken: $fcmToken, lastMessage: $lastMessage)';
  }

  // Add this copyWith method
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? fcmToken,
    String? status,
    Map<String, dynamic>? lastMessage,
    int? unreadCounter,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounter: unreadCounter ?? this.unreadCounter,
    );
}
}