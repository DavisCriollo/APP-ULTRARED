class Formstatus { 
  final bool isPosted;
  final bool isPosting;

  Formstatus({ 
    this.isPosted = false,
    this.isPosting = false,
  });

  Formstatus copyWith({
    bool? isFormValid,
    bool? isPosted,
    bool? isPosting,
  }) {
    return Formstatus( 
      isPosted: isPosted ?? this.isPosted,
      isPosting: isPosting ?? this.isPosting,
    );
  }
}
