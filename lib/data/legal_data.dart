class LegalSection {
  final String title;
  final String content;

  const LegalSection({required this.title, required this.content});
}

const privacySections = [
  LegalSection(
    title: '1. Information We Collect',
    content: 'We collect information you provide directly, such as your name, email address, and profile photo. We also collect scan data including plant images and results to improve our service.',
  ),
  LegalSection(
    title: '2. How We Use Your Information',
    content: 'We use your information to provide and improve Plant Pulse services, personalize your experience, and send you important updates about your account.',
  ),
  LegalSection(
    title: '3. Data Storage',
    content: 'Your data is stored securely on our servers. Plant scan images are processed to detect diseases and are stored to maintain your scan history.',
  ),
  LegalSection(
    title: '4. Data Sharing',
    content: 'We do not sell or share your personal information with third parties. Your data is only used to provide Plant Pulse services.',
  ),
  LegalSection(
    title: '5. Your Rights',
    content: 'You can access, update, or delete your personal data at any time through your profile settings. You may also contact us to request data deletion.',
  ),
  LegalSection(
    title: '6. Contact Us',
    content: 'If you have any questions about this Privacy Policy, please contact us through the Contact Us section in your profile.',
  ),
];

const termsSections = [
  LegalSection(
    title: '1. Acceptance of Terms',
    content: 'By using Plant Pulse, you agree to these Terms of Use. If you do not agree, please do not use the app.',
  ),
  LegalSection(
    title: '2. Use of the App',
    content: 'Plant Pulse is designed for lettuce plant health scanning. You agree to use the app only for lawful purposes and in a manner that does not harm others.',
  ),
  LegalSection(
    title: '3. Account Responsibility',
    content: 'You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use of your account.',
  ),
  LegalSection(
    title: '4. Scan Results',
    content: 'Scan results are provided for informational purposes only. Plant Pulse does not guarantee 100% accuracy. Always consult an agricultural expert for critical decisions.',
  ),
  LegalSection(
    title: '5. Intellectual Property',
    content: 'All content, features, and functionality of Plant Pulse are owned by us and protected by intellectual property laws.',
  ),
  LegalSection(
    title: '6. Changes to Terms',
    content: 'We may update these terms from time to time. Continued use of the app after changes means you accept the new terms.',
  ),
];