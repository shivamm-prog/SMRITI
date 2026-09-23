import React from 'react';
import {
  Home,
  Sparkles,
  Heart,
  Clock,
  TrendingUp,
  User,
  ClipboardList,
  FileText,
  BookOpen,
  Activity,
  Award
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function BottomNav({ activeTab, onTabChange }) {
  const { role } = useAuth();

  return (
    <nav className="bottom-nav" aria-label="Mobile Bottom Navigation">
      {role === 'patient' && (
        <>
          <button
            className={`bottom-nav-item ${activeTab === 'home' ? 'active' : ''}`}
            onClick={() => onTabChange('home')}
          >
            <Home size={22} />
            <span>Home</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'activities' ? 'active' : ''}`}
            onClick={() => onTabChange('activities')}
          >
            <Sparkles size={22} />
            <span>Activities</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'memories' ? 'active' : ''}`}
            onClick={() => onTabChange('memories')}
          >
            <Heart size={22} />
            <span>Memories</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'reminders' ? 'active' : ''}`}
            onClick={() => onTabChange('reminders')}
          >
            <Clock size={22} />
            <span>Reminders</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'progress' ? 'active' : ''}`}
            onClick={() => onTabChange('progress')}
          >
            <TrendingUp size={22} />
            <span>Progress</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'profile' ? 'active' : ''}`}
            onClick={() => onTabChange('profile')}
          >
            <User size={22} />
            <span>Profile</span>
          </button>
        </>
      )}

      {role === 'caregiver' && (
        <>
          <button
            className={`bottom-nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}
            onClick={() => onTabChange('dashboard')}
          >
            <Home size={22} />
            <span>Dashboard</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'notes' ? 'active' : ''}`}
            onClick={() => onTabChange('notes')}
          >
            <ClipboardList size={22} />
            <span>Notes</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'reminders' ? 'active' : ''}`}
            onClick={() => onTabChange('reminders')}
          >
            <Clock size={22} />
            <span>Reminders</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'memories' ? 'active' : ''}`}
            onClick={() => onTabChange('memories')}
          >
            <Heart size={22} />
            <span>Memories</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'resources' ? 'active' : ''}`}
            onClick={() => onTabChange('resources')}
          >
            <BookOpen size={22} />
            <span>Resources</span>
          </button>
        </>
      )}

      {role === 'doctor' && (
        <>
          <button
            className={`bottom-nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}
            onClick={() => onTabChange('dashboard')}
          >
            <Activity size={22} />
            <span>Overview</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'details' ? 'active' : ''}`}
            onClick={() => onTabChange('details')}
          >
            <User size={22} />
            <span>Patient</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'insights' ? 'active' : ''}`}
            onClick={() => onTabChange('insights')}
          >
            <Award size={22} />
            <span>Insights</span>
          </button>
          <button
            className={`bottom-nav-item ${activeTab === 'reports' ? 'active' : ''}`}
            onClick={() => onTabChange('reports')}
          >
            <FileText size={22} />
            <span>Reports</span>
          </button>
        </>
      )}
    </nav>
  );
}
