class TipCategory {
  final String image;
  final String title;
  final List<String> tips;

  const TipCategory({
    required this.image,
    required this.title,
    required this.tips,
  });
}

const plantCareCategories = [
  TipCategory(
    image: 'assets/watering.png',
    title: 'Watering',
    tips: [
      'Water lettuce when the top 2 inches of soil feel dry.',
      'Avoid overwatering — it causes yellow leaves and root rot.',
      'Water in the morning to reduce evaporation.',
      'Use drip irrigation for best results.',
    ],
  ),
  TipCategory(
    image: 'assets/sunlight.png',
    title: 'Sunlight',
    tips: [
      'Lettuce needs 6 hours of sunlight per day.',
      'In hot weather, provide afternoon shade to prevent bolting.',
      'Grow lights work well if natural light is limited.',
    ],
  ),
  TipCategory(
    image: 'assets/soil.png',
    title: 'Soil',
    tips: [
      'Use well-draining, fertile soil with pH 6.0–7.0.',
      'Add compost to improve soil quality.',
      'Avoid compacted soil — lettuce roots need air.',
    ],
  ),
  TipCategory(
    image: 'assets/temperature.png',
    title: 'Temperature',
    tips: [
      'Lettuce grows best between 15°C and 20°C.',
      'High temperatures cause bolting (going to seed).',
      'Frost can damage leaves — use a cover if needed.',
    ],
  ),
  TipCategory(
    image: 'assets/harvesting.png',
    title: 'Harvesting',
    tips: [
      'Harvest outer leaves first to keep the plant growing.',
      'Best harvested in the morning when leaves are crisp.',
      'Full head harvest: cut 1 inch above the soil.',
      'Don\'t wait too long — overgrown lettuce tastes bitter.',
    ],
  ),
];