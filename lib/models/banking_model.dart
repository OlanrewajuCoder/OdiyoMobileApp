class Banking {
  final String? userID;
  final String? bankName;
  final String? accountName;
  final String? accountNo;
  final String? routingNo;
  final String? country;

  Banking({
    this.userID,
    this.bankName,
    this.accountName,
    this.accountNo,
    this.routingNo,
    this.country,
  });


  Banking.fromJson(Map<String, Object?> json)
      : this(
    userID: json['userID']! as String,
    bankName: json['bankName']! as String,
    accountName: json['accountName']! as String,
    accountNo: json['accountNo']! as String,
    routingNo: json['routingNo']! as String,
    country: json['country']! as String,
  );

}
