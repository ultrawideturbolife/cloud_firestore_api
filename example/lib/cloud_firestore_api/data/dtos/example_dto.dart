class ExampleDTO {
  ExampleDTO({
    required this.thisIsAString,
    required this.thisIsANumber,
    required this.thisIsABoolean,
  });

  final String thisIsAString;
  final double thisIsANumber;
  final bool thisIsABoolean;

  factory ExampleDTO.fromJson(Map<String, dynamic> json) => ExampleDTO(
        thisIsAString: json["thisIsAString"],
        thisIsANumber: json["thisIsANumber"],
        thisIsABoolean: json["thisIsABoolean"],
      );

  Map<String, dynamic> toJson() => {
        "thisIsAString": thisIsAString,
        "thisIsANumber": thisIsANumber,
        "thisIsABoolean": thisIsABoolean,
      };
}
