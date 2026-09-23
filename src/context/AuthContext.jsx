import React, { createContext, useContext, useState, useEffect } from 'react';
import { storageService } from '../services/storageService';
import { INITIAL_USERS } from '../data/initialMockData';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(() => storageService.getCurrentUser());
  const [allUsers, setAllUsers] = useState(() => storageService.getUsers());
  const [isOnboarding, setIsOnboarding] = useState(false);

  useEffect(() => {
    storageService.initialize();
    const loadedUser = storageService.getCurrentUser();
    const loadedAll = storageService.getUsers();
    setCurrentUser(loadedUser);
    setAllUsers(loadedAll);
  }, []);

  // Quick switch role (Dev / SIH Evaluation helper)
  const switchRole = (newRole) => {
    const matchingUser = allUsers.find(u => u.role === newRole);
    if (matchingUser) {
      setCurrentUser(matchingUser);
      storageService.setCurrentUser(matchingUser);
    } else {
      // Fallback default role user
      const defaultForRole = INITIAL_USERS.find(u => u.role === newRole) || {
        id: `user-${newRole}-${Date.now()}`,
        role: newRole,
        name: `Sample ${newRole.charAt(0).toUpperCase() + newRole.slice(1)}`,
        region: 'assam',
        language: 'English'
      };
      setCurrentUser(defaultForRole);
      storageService.setCurrentUser(defaultForRole);
    }
  };

  const loginAsUser = (userId) => {
    const target = allUsers.find(u => u.id === userId);
    if (target) {
      setCurrentUser(target);
      storageService.setCurrentUser(target);
      setIsOnboarding(false);
    }
  };

  const completeOnboarding = (userData) => {
    const newUser = {
      id: `user-${userData.role}-${Date.now()}`,
      ...userData,
      createdAt: new Date().toISOString()
    };
    storageService.addUser(newUser);
    storageService.setCurrentUser(newUser);
    setCurrentUser(newUser);
    setAllUsers(storageService.getUsers());
    setIsOnboarding(false);
    return newUser;
  };

  const updateProfile = (profileData) => {
    const updated = storageService.updateUserProfile(profileData);
    setCurrentUser(updated);
    setAllUsers(storageService.getUsers());
    return updated;
  };

  const logout = () => {
    setIsOnboarding(true);
  };

  const startOnboarding = () => {
    setIsOnboarding(true);
  };

  const cancelOnboarding = () => {
    setIsOnboarding(false);
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        role: currentUser?.role || 'patient',
        allUsers,
        isOnboarding,
        switchRole,
        loginAsUser,
        completeOnboarding,
        updateProfile,
        logout,
        startOnboarding,
        cancelOnboarding
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
