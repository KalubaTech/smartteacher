class MySubscription {
  String uid;
  String amount;
  String plan;
  DateTime dateTime;
  DateTime expiry_date;
  bool isActive;

  MySubscription({
    required this.uid,
    required this.plan,
    required this.amount,
    required this.dateTime,
    required this.isActive,
    required this.expiry_date,
  });
}