// Initial Mock Data for MindSetu (LocalStorage Seeding)

export const INITIAL_USERS = [
  {
    id: 'user-pat-01',
    role: 'patient',
    name: 'Bhaben Borah',
    age: 72,
    gender: 'Male',
    dob: '1954-04-14',
    region: 'assam',
    regionName: 'Assam',
    language: 'Assamese',
    avatar: '👴',
    emergencyContact: {
      name: 'Anamika Borah (Daughter / Caregiver)',
      phone: '+91 94350 12345',
      relation: 'Daughter'
    },
    preferences: {
      activities: ['Morning tea on the veranda', 'Gardening & caring for plants', 'Listening to folk songs & radio'],
      foods: ['Fresh Masor Tenga / sour fish curry', 'Soft Pitha with jaggery', 'Warm herbal tea & ginger'],
      music: ['Gentle Bihu songs & Pepa', 'Soothing sound of rain on tin roof'],
      places: ['Lush Green Tea Garden', 'Peaceful Riverbank / Lake Shore']
    },
    cognitiveStage: 'Mild Memory Support',
    doctorName: 'Dr. Sarma (Neurology / Geriatric Care)',
    lastActive: 'Today, 8:30 AM'
  },
  {
    id: 'user-cg-01',
    role: 'caregiver',
    name: 'Anamika Borah',
    age: 42,
    gender: 'Female',
    relation: 'Daughter & Primary Caregiver',
    assignedPatientId: 'user-pat-01',
    phone: '+91 94350 12345',
    region: 'assam',
    avatar: '👩‍⚕️'
  },
  {
    id: 'user-doc-01',
    role: 'doctor',
    name: 'Dr. Debabrata Sarma',
    qualification: 'MD, Geriatric Medicine & Cognitive Health',
    hospital: 'Guwahati Neurological & Senior Wellness Institute',
    license: 'NMC-NER-44821',
    avatar: '👨‍⚕️'
  }
];

export const INITIAL_REMINDERS = [
  {
    id: 'rem-1',
    patientId: 'user-pat-01',
    title: 'Morning Blood Pressure & Memory Vitamin',
    category: 'Medicine',
    icon: 'Pill',
    time: '08:30 AM',
    period: 'Morning',
    instructions: 'Take 1 tablet with warm water after light breakfast.',
    completed: true,
    completedAt: 'Today, 08:35 AM',
    verifiedByCaregiver: true
  },
  {
    id: 'rem-2',
    patientId: 'user-pat-01',
    title: 'Warm Ginger & Lemongrass Tea',
    category: 'Hydration',
    icon: 'Coffee',
    time: '11:00 AM',
    period: 'Morning',
    instructions: 'Sip a warm cup of herbal tea and rest in the veranda.',
    completed: false,
    completedAt: null,
    verifiedByCaregiver: false
  },
  {
    id: 'rem-3',
    patientId: 'user-pat-01',
    title: 'Wholesome Lunch with Masor Tenga',
    category: 'Meal',
    icon: 'Utensils',
    time: '01:15 PM',
    period: 'Afternoon',
    instructions: 'Fresh steamed rice and gentle fish broth prepared by Anamika.',
    completed: false,
    completedAt: null,
    verifiedByCaregiver: false
  },
  {
    id: 'rem-4',
    patientId: 'user-pat-01',
    title: 'Gentle Garden Stroll with Family',
    category: 'Daily Activity',
    icon: 'Footprints',
    time: '04:45 PM',
    period: 'Evening',
    instructions: '15-minute peaceful stroll on the lawn to admire the marigolds.',
    completed: false,
    completedAt: null,
    verifiedByCaregiver: false
  },
  {
    id: 'rem-5',
    patientId: 'user-pat-01',
    title: 'Night Sleep Well Capsule',
    category: 'Medicine',
    icon: 'Moon',
    time: '09:00 PM',
    period: 'Night',
    instructions: 'Take 1 capsule before tucking in for restful sleep.',
    completed: false,
    completedAt: null,
    verifiedByCaregiver: false
  }
];

export const INITIAL_MEMORIES = [
  {
    id: 'mem-1',
    patientId: 'user-pat-01',
    title: 'Rongali Bihu with Grandchildren',
    date: 'April 14, 2024',
    location: 'Tezpur Family Courtyard, Assam',
    people: 'Anamika (Daughter), Joy (Grandson), Parishmita (Granddaughter)',
    description: 'We sat in the courtyard wearing our festive Muga Gamusa. Joy danced the Bihu steps with the dhol beat, and we enjoyed freshly baked Til Pitha and warm tea together.',
    emojiPhoto: '🌾 🪕 👨‍👩‍👧‍👦',
    tags: ['Family', 'Bihu', 'Festive', 'Courtyard'],
    voiceNoteTitle: 'Grandson laughing & Bihu dhol rhythm (32s)',
    voiceDuration: '0:32',
    recallQuestion: 'Who was playing the small Bihu drum in the courtyard?',
    recallAnswer: 'Joy (Your grandson)',
    recallHint: 'Your cheerful 10-year-old grandson wearing a silk waistcoat.'
  },
  {
    id: 'mem-2',
    patientId: 'user-pat-01',
    title: 'Visit to Kaziranga National Park',
    date: 'November 2022',
    location: 'Kohora Range, Kaziranga',
    people: 'Late Wife (Nirmala) and Bhaben',
    description: 'The golden morning mist was rising over the elephant grass. We spotted a mother rhino and her gentle calf grazing near the quiet stream. Nirmala held my hand and smiled.',
    emojiPhoto: '🦏 🌄 🌿',
    tags: ['Nature', 'Wife', 'Kaziranga', 'Peaceful'],
    voiceNoteTitle: 'Morning birdsong near Kohora range (45s)',
    voiceDuration: '0:45',
    recallQuestion: 'What beautiful animal did you and Nirmala watch near the quiet stream?',
    recallAnswer: 'A mother one-horned rhinoceros and her gentle calf',
    recallHint: 'The majestic animal Assam is known for across the world.'
  },
  {
    id: 'mem-3',
    patientId: 'user-pat-01',
    title: 'Building our Veranda Tea Table',
    date: 'Spring 2018',
    location: 'Home Garden, Jorhat',
    people: 'Bhaben Borah and Village Carpenter Mukul',
    description: 'We hand-selected local seasoned teak wood from the nearby hills. This table has held thousands of warm morning tea cups and lively family conversations over the years.',
    emojiPhoto: '🪵 ☕ 🏡',
    tags: ['Home', 'Garden', 'Tea Table', 'Craft'],
    voiceNoteTitle: 'Sounds of rain on the veranda roof (1:10)',
    voiceDuration: '1:10',
    recallQuestion: 'Where does your favourite teak wood table sit in the house?',
    recallAnswer: 'On the front veranda facing the garden',
    recallHint: 'Where you sit every morning watching the green tea bushes and flowers.'
  }
];

export const INITIAL_DAILY_NOTES = [
  {
    id: 'note-1',
    patientId: 'user-pat-01',
    author: 'Anamika Borah (Caregiver)',
    date: 'Today, 8:40 AM',
    timestamp: '2026-09-02T08:40:00',
    mood: 'Calm & Happy',
    moodEmoji: '😊',
    sleepQuality: 'Good (7.5 hours uninterrupted)',
    appetite: 'Normal — enjoyed soft pitha & warm tea',
    behavior: 'Pleasant and conversational. Talked about old Tezpur memories when looking at his Gamusa.',
    observations: 'Smiled warmly during morning tea. Completed his BP pill without reluctance.'
  },
  {
    id: 'note-2',
    patientId: 'user-pat-01',
    author: 'Anamika Borah (Caregiver)',
    date: 'Yesterday, 8:15 PM',
    timestamp: '2026-09-01T20:15:00',
    mood: 'Slightly Tired in Evening',
    moodEmoji: '😌',
    sleepQuality: 'Mild afternoon nap (40 mins)',
    appetite: 'Finished full dinner of steamed rice and dal',
    behavior: 'Needed gentle encouragement around 5 PM to recall where his spectacles were.',
    observations: 'Played the Nature Spotting activity and was very proud of spotting the Kopou orchid.'
  },
  {
    id: 'note-3',
    patientId: 'user-pat-01',
    author: 'Anamika Borah (Caregiver)',
    date: 'Aug 31, 2026',
    timestamp: '2026-08-31T19:00:00',
    mood: 'Very Cheerful',
    moodEmoji: '🌟',
    sleepQuality: 'Restful 8 hours',
    appetite: 'Excellent',
    behavior: 'Listened to Bihu flute on the tablet and tapped his hands along with the rhythm.',
    observations: 'Great day overall. Visited the neighbor garden for 20 minutes.'
  }
];

export const INITIAL_ACTIVITY_RESULTS = [
  {
    id: 'res-1',
    patientId: 'user-pat-01',
    activityId: 'act-memory-recall',
    activityTitle: 'Familiar Places & Memories',
    category: 'Memory Recall',
    score: 100,
    totalQuestions: 3,
    correctCount: 3,
    completedAt: 'Today, 8:15 AM',
    timestamp: '2026-09-02T08:15:00',
    durationSeconds: 142,
    feedback: 'Splendid memory! You recognised all three serene landmarks effortlessly.'
  },
  {
    id: 'res-2',
    patientId: 'user-pat-01',
    activityId: 'act-matching',
    activityTitle: 'Cultural Pairs of the Hills',
    category: 'Matching',
    score: 85,
    totalQuestions: 6,
    correctCount: 5,
    completedAt: 'Yesterday, 4:30 PM',
    timestamp: '2026-09-01T16:30:00',
    durationSeconds: 180,
    feedback: 'Warm effort! Matched traditional treasures with steady focus.'
  },
  {
    id: 'res-3',
    patientId: 'user-pat-01',
    activityId: 'act-attention',
    activityTitle: 'Gentle Nature Spotting',
    category: 'Attention',
    score: 95,
    totalQuestions: 3,
    correctCount: 3,
    completedAt: 'Yesterday, 11:20 AM',
    timestamp: '2026-09-01T11:20:00',
    durationSeconds: 98,
    feedback: 'Wonderful calm attention! Spotted the orchid and hornbill with gentle ease.'
  },
  {
    id: 'res-4',
    patientId: 'user-pat-01',
    activityId: 'act-sequence',
    activityTitle: 'Making Morning Assam Tea',
    category: 'Sequence',
    score: 100,
    totalQuestions: 4,
    correctCount: 4,
    completedAt: 'Aug 31, 2026',
    timestamp: '2026-08-31T09:10:00',
    durationSeconds: 110,
    feedback: 'Perfect daily routine sequencing! Remembered all kitchen steps seamlessly.'
  }
];

export const INITIAL_CLINICAL_INSIGHTS = [
  {
    id: 'ins-1',
    patientId: 'user-pat-01',
    type: 'Positive Continuity',
    badge: 'Consistent Routine',
    severity: 'positive',
    title: 'Strong Procedural & Routine Sequencing',
    summary: 'Patient consistently scores 95–100% on sequential daily life tasks (e.g. Making Tea, Morning routine). Semantic connection to familiar regional items remains robust.',
    clinicalAdvice: 'Encourage continued participation in familiar daily kitchen & garden habits to preserve procedural independence.',
    generatedAt: 'Today, 06:00 AM',
    disclaimer: 'AI-assisted clinical insight — final evaluation and diagnostic judgment remain with the consulting physician.'
  },
  {
    id: 'ins-2',
    patientId: 'user-pat-01',
    type: 'Observation Trend',
    badge: 'Gentle Attention Note',
    severity: 'neutral',
    title: 'Afternoon Attention Fluctuations Correlate with Nap Duration',
    summary: 'Slight increase in reaction time (avg +18s) during 4:00 PM – 5:30 PM activities on days when afternoon rest is shorter than 30 minutes.',
    clinicalAdvice: 'Recommend caregiver maintains a quiet 30–45 minute afternoon rest window to sustain evening alertness.',
    generatedAt: 'Yesterday, 07:00 PM',
    disclaimer: 'AI-assisted clinical insight — final evaluation and diagnostic judgment remain with the consulting physician.'
  },
  {
    id: 'ins-3',
    patientId: 'user-pat-01',
    type: 'Adherence',
    badge: 'High Adherence',
    severity: 'positive',
    title: 'Medicine & Hydration Adherence at 94%',
    summary: 'Caregiver verification confirms 17 of 18 scheduled reminders completed on time over the past 5 days with high patient cooperation.',
    clinicalAdvice: 'Current visual and voice prompt configuration is working effectively. No adjustment required.',
    generatedAt: 'Aug 30, 2026',
    disclaimer: 'AI-assisted clinical insight — final evaluation and diagnostic judgment remain with the consulting physician.'
  }
];

export const CAREGIVER_RESOURCES = [
  {
    id: 'res-c1',
    title: 'Communicating with Compassion & Calm in Dementia',
    category: 'Communication',
    readTime: '4 mins read',
    summary: 'Practical tips on speaking in gentle tones, using simple choices, and avoiding confrontation when memory slips occur.',
    keyPoints: [
      'Maintain eye contact and smile warmly before speaking.',
      'Use short, comforting sentences rather than long questions.',
      'Acknowledge the feeling behind words instead of arguing over forgotten facts.',
      'Use culturally familiar gestures, such as offering warm tea.'
    ]
  },
  {
    id: 'res-c2',
    title: 'Creating a Soothing Daily Rhythm in the North East',
    category: 'Daily Care',
    readTime: '5 mins read',
    summary: 'Structuring elderly days around gentle natural cycles: morning sunrise, veranda tea, light gardening, and calming music.',
    keyPoints: [
      'Keep waking and sleeping times predictable.',
      'Incorporate morning sun on the balcony or garden.',
      'Play gentle traditional instruments (Bihu flute, Pena, hymns) during evening restlessness.',
      'Involve the patient in small, safe sensory tasks like folding Gamusas or plucking herbs.'
    ]
  },
  {
    id: 'res-c3',
    title: 'Managing Evening Restlessness ("Sundowning")',
    category: 'Behavior & Comfort',
    readTime: '4 mins read',
    summary: 'Why confusion often rises as dusk falls, and how warm lighting and familiar family routines help ease tension.',
    keyPoints: [
      'Close window curtains and turn on warm room lights before natural twilight arrives.',
      'Offer a small warm comforting snack like black rice kheer or warm ginger milk.',
      'Avoid loud television news or overwhelming visits late in the day.',
      'Sit together and review the Family Memory Journal in MindSetu.'
    ]
  },
  {
    id: 'res-c4',
    title: 'North Eastern Regional Support & Community Directory',
    category: 'Support Network',
    readTime: '3 mins read',
    summary: 'Local senior citizen welfare helplines, community elder circles, and geriatric tele-consultation centres across the 8 NER states.',
    keyPoints: [
      'National Elder Helpline (Toll-Free): 14567',
      'Guwahati Neurological & Senior Wellness Network: 0361-2458900',
      'Shillong Senior Care & Memory Support Circle: 0364-2223450',
      'Tele-MANAS Mental Health Support: 14416 (24x7 Multi-lingual)'
    ]
  }
];
