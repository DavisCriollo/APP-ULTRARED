class Formstatus {
  final bool isFormValid;
  final bool isPosted;
  final bool isPosting;

  Formstatus({
    this.isFormValid = false,
    this.isPosted = false,
    this.isPosting = false,
  });

  Formstatus copyWith({
    bool? isFormValid,
    bool? isPosted,
    bool? isPosting,
  }) {
    return Formstatus(
      isFormValid: isFormValid ?? this.isFormValid,
      isPosted: isPosted ?? this.isPosted,
      isPosting: isPosting ?? this.isPosting,
    );
  }
}
