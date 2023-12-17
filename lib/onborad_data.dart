class OnBoarding {
  final String title;
  final String image;
  final String description;

  OnBoarding({
    required this.title,
    required this.image,
    required this.description,
  });
}

List<OnBoarding> onboardingContents = [
  OnBoarding(
    title: 'WELCOME\n Before you start using\n the app, learn how to use it!',
    description: "Read carefully\n and don't skip a step!",
    image: 'assets/images/body.png',
  ),
  OnBoarding(
    title: '1. Camera settings:',
    image: 'assets/images/smartphone.png',
    description: "Take close-up photos of the objects and wait for the image to focus on the subject. Avoid glare from light on the patient's skin. ",

  ),
  OnBoarding(
    title: '2. Lighting:',
    image: 'assets/images/spotlight.png',
    description: "Prepare the patient and the photo area. Ensure good lighting on the patient's skin and remove clothing or accessories for optimal photo quality.",

  ),
  OnBoarding(
    title: '3. Stabilization:',
    image: 'assets/images/phone-camera.png',
    description: "Ensure patient stabilization and proper positioning to capture a clear photo of the skin lesion. Consider using a tripod or similar device for stability.",

  ),
  OnBoarding(
    title: '4. Use the app',
    image: 'assets/images/dermatology.png',
    description: "Make sure you are close enough to get a detailed image, but not too close to avoid distortion. Take a photo. You also have the option of uploading photos from the gallery.",

  ),
];