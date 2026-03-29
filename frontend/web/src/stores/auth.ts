import { create } from 'zustand'

interface AuthState {
  token: string | null
  username: string | null
  isSuper: boolean
  isAuthenticated: boolean
  login: (token: string, username: string, isSuper: boolean) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  token: localStorage.getItem('token'),
  username: localStorage.getItem('username'),
  isSuper: localStorage.getItem('isSuper') === 'true',
  isAuthenticated: !!localStorage.getItem('token'),

  login: (token: string, username: string, isSuper: boolean) => {
    localStorage.setItem('token', token)
    localStorage.setItem('username', username)
    localStorage.setItem('isSuper', String(isSuper))
    set({ token, username, isSuper, isAuthenticated: true })
  },

  logout: () => {
    localStorage.removeItem('token')
    localStorage.removeItem('username')
    localStorage.removeItem('isSuper')
    set({ token: null, username: null, isSuper: false, isAuthenticated: false })
  },
}))
