// Cognitive Activities Definitions & Data for MindSetu

export const ACTIVITIES = [
  {
    id: 'act-memory-recall',
    type: 'Memory Recall',
    title: 'Familiar Places & Memories',
    category: 'Memory Recall',
    difficulty: 'Gentle & Calming',
    estimatedMinutes: '3–5 mins',
    icon: 'Brain',
    color: '#2563EB',
    bgLight: '#EFF6FF',
    description: 'Look at peaceful pictures of our beautiful North East and remember their stories.',
    instructions: 'Look closely at the picture. Take all the time you need. Then tap the answer that feels right.',
    questions: [
      {
        id: 'q1',
        title: 'Where is this serene sanctuary?',
        imagePrompt: 'Kaziranga National Park with one-horned rhinoceros grazing peacefully near water',
        imageEmoji: '🦏 🌿',
        imagePlaceholderText: 'Kaziranga National Park Sanctuary',
        imageLocation: 'Golaghat & Nagaon, Assam',
        hint: 'Famous worldwide for the gentle one-horned rhinoceros.',
        options: [
          'Kaziranga National Park (Assam)',
          'Marina Beach (Chennai)',
          'Thar Desert (Rajasthan)'
        ],
        correctIndex: 0,
        explanation: 'Wonderful! Kaziranga in Assam is the peaceful home of our majestic one-horned rhinoceros.'
      },
      {
        id: 'q2',
        title: 'Which traditional living bridge is grown from rubber tree roots?',
        imagePrompt: 'Living Root Bridges of Meghalaya hanging over crystal green forest stream',
        imageEmoji: '🌉 🌳',
        imagePlaceholderText: 'Living Root Bridge',
        imageLocation: 'Cherrapunji, Meghalaya',
        hint: 'Grown with love and patience over generations by Khasi and Jaintia tribes.',
        options: [
          'Howrah Bridge',
          'Living Root Bridge (Meghalaya)',
          'Golden Gate Bridge'
        ],
        correctIndex: 1,
        explanation: 'Spot on! The Living Root Bridges of Meghalaya are grown naturally from living tree roots.'
      },
      {
        id: 'q3',
        title: 'Which majestic palace sits by the quiet lake in Agartala?',
        imagePrompt: 'Ujjayanta Palace shining white in Tripura reflecting on the royal lake',
        imageEmoji: '🏰 💧',
        imagePlaceholderText: 'Ujjayanta Palace',
        imageLocation: 'Agartala, Tripura',
        hint: 'A grand white palace named by Nobel laureate Rabindranath Tagore.',
        options: [
          'Mysore Palace',
          'Red Fort',
          'Ujjayanta Palace (Tripura)'
        ],
        correctIndex: 2,
        explanation: 'Heartwarming! Ujjayanta Palace is the historic royal crown of Tripura.'
      }
    ]
  },
  {
    id: 'act-matching',
    type: 'Matching',
    title: 'Cultural Pairs of the Hills',
    category: 'Matching',
    difficulty: 'Relaxed & Pleasant',
    estimatedMinutes: '4 mins',
    icon: 'Sparkles',
    color: '#0D9488',
    bgLight: '#F0FDFA',
    description: 'Match familiar traditional objects and cultural treasures with their pairs.',
    instructions: 'Tap two cards to reveal them. Find the pairs that belong together. Take your time!',
    pairs: [
      { id: 'p1', name: 'Assam Tea Cup', emoji: '☕', detail: 'Warm CTC Tea' },
      { id: 'p2', name: 'Gamusa Cloth', emoji: '🧣', detail: 'Red & White Weave' },
      { id: 'p3', name: 'Bamboo Basket', emoji: '🧺', detail: 'Handcrafted Cane' },
      { id: 'p4', name: 'Pepa Flute', emoji: '🎺', detail: 'Buffalo Horn' },
      { id: 'p5', name: 'Fresh Momos', emoji: '🥟', detail: 'Warm Herbal Broth' },
      { id: 'p6', name: 'Lotus Flower', emoji: '🪷', detail: 'Loktak Lake Lotus' }
    ]
  },
  {
    id: 'act-sequence',
    type: 'Sequence',
    title: 'Making Morning Assam Tea',
    category: 'Sequence',
    difficulty: 'Very Gentle',
    estimatedMinutes: '3 mins',
    icon: 'ListOrdered',
    color: '#7C3AED',
    bgLight: '#F5F3FF',
    description: 'Arrange the daily steps of brewing a comforting, warm cup of morning tea.',
    instructions: 'Tap the steps in the order you would do them in your kitchen, starting from step 1.',
    steps: [
      { id: 's1', order: 1, text: 'Pour clean water into the kettle and place on flame', icon: '🫖' },
      { id: 's2', order: 2, text: 'Add aromatic tea leaves and crushed fresh ginger', icon: '🌿' },
      { id: 's3', order: 3, text: 'Pour warm fresh milk and let it gently simmer', icon: '🥛' },
      { id: 's4', order: 4, text: 'Strain into your favourite cup and enjoy on the veranda', icon: '☕' }
    ]
  },
  {
    id: 'act-attention',
    type: 'Attention',
    title: 'Gentle Nature Spotting',
    category: 'Attention',
    difficulty: 'Gentle Focus',
    estimatedMinutes: '3 mins',
    icon: 'Eye',
    color: '#0284C7',
    bgLight: '#F0F9FF',
    description: 'Gently look across a soothing garden scene and spot peaceful nature items.',
    instructions: 'Look for the target item shown at the top. Tap it gently when you spot it in the garden.',
    rounds: [
      {
        target: 'Foxtail Orchid (Kopou Phool)',
        targetEmoji: '🌸',
        targetDescription: 'The sacred pink Kopou orchid worn during Rongali Bihu.',
        grid: [
          { id: 'i1', emoji: '🍃', label: 'Green Leaf' },
          { id: 'i2', emoji: '🌿', label: 'Fern' },
          { id: 'i3', emoji: '🌸', label: 'Foxtail Orchid', isTarget: true },
          { id: 'i4', emoji: '🌾', label: 'Paddy Reed' },
          { id: 'i5', emoji: '🍃', label: 'Green Leaf' },
          { id: 'i6', emoji: '🌱', label: 'Sprout' }
        ]
      },
      {
        target: 'Gentle Great Hornbill Bird',
        targetEmoji: '🦜',
        targetDescription: 'The revered majestic bird celebrated in Nagaland and Arunachal.',
        grid: [
          { id: 'i7', emoji: '🕊️', label: 'Dove' },
          { id: 'i8', emoji: '🦜', label: 'Great Hornbill', isTarget: true },
          { id: 'i9', emoji: '🌿', label: 'Pine Branch' },
          { id: 'i10', emoji: '🌾', label: 'Grass' },
          { id: 'i11', emoji: '🍃', label: 'Leaf' },
          { id: 'i12', emoji: '🪵', label: 'Log' }
        ]
      },
      {
        target: 'Handwoven Bamboo Japi',
        targetEmoji: '👒',
        targetDescription: 'The iconic traditional conical hat made of bamboo and tokou leaves.',
        grid: [
          { id: 'i13', emoji: '🧺', label: 'Basket' },
          { id: 'i14', emoji: '🧣', label: 'Cloth' },
          { id: 'i15', emoji: '🎋', label: 'Bamboo Pole' },
          { id: 'i16', emoji: '👒', label: 'Bamboo Japi', isTarget: true },
          { id: 'i17', emoji: '🥣', label: 'Clay Bowl' },
          { id: 'i18', emoji: '🪵', label: 'Wood' }
        ]
      }
    ]
  },
  {
    id: 'act-recognition',
    type: 'Recognition',
    title: 'Instruments of the North East',
    category: 'Recognition',
    difficulty: 'Comforting & Musical',
    estimatedMinutes: '3 mins',
    icon: 'Music',
    color: '#D97706',
    bgLight: '#FFFBEB',
    description: 'Listen to the memory of traditional melodies and identify the traditional instrument.',
    instructions: 'Read the gentle clue and tap the musical instrument you recognise.',
    items: [
      {
        id: 'rec1',
        title: 'Which instrument is crafted from buffalo horn and bamboo?',
        audioSimulationText: 'High, joyful melodic call heard during spring Bihu dances...',
        clue: 'Plays the soul-stirring tune that welcomes the arrival of spring.',
        options: [
          { name: 'Pepa (Horn Flute)', emoji: '🎺', isCorrect: true },
          { name: 'Piano', emoji: '🎹', isCorrect: false },
          { name: 'Electric Guitar', emoji: '🎸', isCorrect: false }
        ],
        explanation: 'Splendid! The Pepa is carved from buffalo horn and plays joyful Bihu tunes.'
      },
      {
        id: 'rec2',
        title: 'Which sacred ancient instrument has a single horsehair string and coconut shell?',
        audioSimulationText: 'Deep, resonant, soulful strings echoing across the Manipur valley...',
        clue: 'Played by traditional balladeers to tell folklore stories in Manipur.',
        options: [
          { name: 'Saxophone', emoji: '🎷', isCorrect: false },
          { name: 'Pena (Lute)', emoji: '🎻', isCorrect: true },
          { name: 'Synthesizer', emoji: '🎛️', isCorrect: false }
        ],
        explanation: 'Very nice! The Pena is an ancient Manipuri bowed instrument with a calming, meditative sound.'
      },
      {
        id: 'rec3',
        title: 'What large wooden hollow drum echoes across hill villages to signal celebrations?',
        audioSimulationText: 'Booming rhythmic wooden beats reverberating through mountain mists...',
        clue: 'Carved from a single massive tree trunk in Naga villages.',
        options: [
          { name: 'Log Drum', emoji: '🥁', isCorrect: true },
          { name: 'Microphone', emoji: '🎙️', isCorrect: false },
          { name: 'Violin', emoji: '🎻', isCorrect: false }
        ],
        explanation: 'Excellent! The traditional Log Drum brings the whole village together with its heartbeat.'
      }
    ]
  },
  {
    id: 'act-language',
    type: 'Language',
    title: 'Familiar Words & Proverbs',
    category: 'Language',
    difficulty: 'Gentle Word Fun',
    estimatedMinutes: '3 mins',
    icon: 'BookOpen',
    color: '#059669',
    bgLight: '#ECFDF5',
    description: 'Connect comforting everyday words and positive proverbs with their meanings.',
    instructions: 'Read the greeting or word and select the gentle meaning that matches.',
    questions: [
      {
        id: 'lang1',
        phrase: 'Khublei Shibun',
        language: 'Khasi (Meghalaya)',
        prompt: 'When someone says "Khublei Shibun", what are they wishing you?',
        options: [
          'Thank you very much / May you be blessed',
          'Good night and sleep tight',
          'Hurry up quickly'
        ],
        correctIndex: 0,
        explanation: '"Khublei Shibun" in Khasi is a warm, heart-filled "Thank you very much and blessings to you".'
      },
      {
        id: 'lang2',
        phrase: 'লাহে লাহে (Lahe Lahe)',
        language: 'Assamese (Assam)',
        prompt: 'In Assam, when people say "Lahe Lahe", what does it encourage us to do?',
        options: [
          'Run as fast as possible',
          'Take life slowly, calmly and at peace',
          'Speak loudly in the room'
        ],
        correctIndex: 1,
        explanation: '"Lahe Lahe" is the beloved Assamese philosophy of calm patience — taking things easy and peacefully.'
      },
      {
        id: 'lang3',
        phrase: 'Chibai',
        language: 'Mizo (Mizoram)',
        prompt: 'What does the cheerful word "Chibai" mean in Mizoram?',
        options: [
          'Hello / Warm Greetings',
          'Bitter medicine',
          'Dark thunderstorm'
        ],
        correctIndex: 0,
        explanation: '"Chibai" is the friendly, smiling greeting used across Mizoram to welcome friends.'
      }
    ]
  }
];
