// SMRITI - Seed Profiles for Patient, Caregiver, and Healthcare Professional
export const SEED_PROFILES = {
  patient: {
    id: "pat_anita_001",
    name: "Anita Das",
    age: 74,
    preferredLanguage: "as", // Default: Assamese ('as', 'hi', 'en')
    location: "Guwahati, Assam",
    bio: "Retired high school science teacher. Enjoys Assam black tea, gardening, Bihu folk songs, and reminiscing about ancestral family memories.",
    emergencyContact: "Rahul Das (+91 98640 54321)",
    assignedCaregiverId: "cg_rahul_001",
    assignedDoctorId: "doc_mehta_001",
    avatar: "👵",
    personalPreferences: {
      favoriteCategory: "nature_and_tea",
      difficultyTier: "gentle",
      voiceSpeed: 0.85,
      highContrast: false,
      fontSize: "large"
    }
  },
  caregiver: {
    id: "cg_rahul_001",
    name: "Rahul Das",
    relationship: "Son & Primary Caregiver",
    phone: "+91 98640 54321",
    email: "rahul.das@example.com",
    assignedPatientId: "pat_anita_001",
    avatar: "👨‍💼"
  },
  doctor: {
    id: "doc_mehta_001",
    name: "Dr. Mehta, MD, DM",
    specialty: "Consultant Geriatrician & Neurologist",
    hospital: "Guwahati Geriatric Cognitive Care Clinic",
    registrationNo: "MC-ASM-51204",
    authorizedPatients: ["pat_anita_001"],
    avatar: "👨‍⚕️"
  }
};