import { request } from './client'
import type { AdminUser, AdminCreateRequest, ResetPasswordResponse } from './types'

export async function listAdmins(): Promise<AdminUser[]> {
  return request<AdminUser[]>('/admins')
}

export async function createAdmin(data: AdminCreateRequest): Promise<AdminUser> {
  return request<AdminUser>('/admins', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}

export async function deleteAdmin(id: number): Promise<void> {
  return request(`/admins/${id}`, { method: 'DELETE' })
}

export async function resetAdminPassword(id: number): Promise<ResetPasswordResponse> {
  return request<ResetPasswordResponse>(`/admins/${id}/reset-password`, { method: 'POST' })
}
