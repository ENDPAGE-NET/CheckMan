import { Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from '../stores/auth'

export default function AuthGuard() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated)
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  return <Outlet />
}
