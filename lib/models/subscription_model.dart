class SubscriptionModel {
  String plan;
  String amount;
  String description;

  // Constructor
  SubscriptionModel({
    required this.plan,
    required this.amount,
    required this.description,
  });

  // Factory constructor to create an instance from a JSON map
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'],
      amount: json['amount'],
      description: json['description'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'amount': amount,
      'description': description,
    };
  }

  // Override toString() for better readability when printing the object
  @override
  String toString() {
    return 'SubscriptionModel(plan: $plan, amount: $amount, description: $description)';
  }

  // Override equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionModel &&
        other.plan == plan &&
        other.amount == amount &&
        other.description == description;
  }

  // Override hashCode for consistency with equality
  @override
  int get hashCode => plan.hashCode ^ amount.hashCode ^ description.hashCode;

  // CopyWith method to create a new instance with updated fields
  SubscriptionModel copyWith({
    String? plan,
    String? amount,
    String? description,
  }) {
    return SubscriptionModel(
      plan: plan ?? this.plan,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}