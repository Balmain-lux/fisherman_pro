class Message {
  String? id;
  String? text;
  String? imageUrl;
  double? latitude;
  double? longitude;
  String? address;
  String? userId;
  String? userName;
  DateTime? createdAt;

  Message({
    this.id,
    this.text,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.userId,
    this.userName,
    this.createdAt,
  });
}
