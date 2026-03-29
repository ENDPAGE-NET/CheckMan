import { request } from './client'
import type { LoginRequest, AdminLoginResponse, ChangePasswordRequest } from './types'

export async function adminLogin(data: LoginRequest): Promise<AdminLoginResponse> {
  return request<AdminLoginResponse>('/admin/login', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}

export async function adminChangePassword(data: ChangePasswordRequest): Promise<{ message: string }> {
  return request('/admin/change-password', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
