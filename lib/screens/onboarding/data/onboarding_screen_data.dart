class OnboardingScreenData {
  String imagePath;
  String title;
  String description;

  OnboardingScreenData(
      {required this.imagePath,
      required this.title,
      required this.description});

  void setImageAssetPath(String imagePath) {
    this.imagePath = imagePath;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setDescription(String description) {
    this.description = description;
  }

  String getImageAssetPath() {
    return this.imagePath;
  }

  String getTitle() {
    return this.title;
  }

  String getDescription() {
    return this.description;
  }
}

List<OnboardingScreenData> getSliders() {
  List<OnboardingScreenData> sliders = List.empty(growable: true);

  sliders.add(new OnboardingScreenData(
      imagePath: "assets/onboarding/illustration1.png",
      title: "Explore content",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris eget vehicula odio, vel viverra leo."));
  sliders.add(new OnboardingScreenData(
      imagePath: "assets/onboarding/illustration2.png",
      title: "Write your own content",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris eget vehicula odio, vel viverra leo."));
  sliders.add(new OnboardingScreenData(
      imagePath: "assets/onboarding/illustration3.png",
      title: "Done!",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris eget vehicula odio, vel viverra leo."));

  return sliders;
}
