import { request } from './client'
import type { Employee, EmployeeStatus, EmployeeUpdateRequest, EmployeeCreateRequest, ResetPasswordResponse } from './types'

export async function listEmployees(params?: {
  status?: EmployeeStatus
  name?: string
}): Promise<Employee[]> {
  const query = new URLSearchParams()
  if (params?.status) query.set('status', params.status)
  if (params?.name) query.set('name', params.name)
  const qs = query.toString()
  return request<Employee[]>(`/employees${qs ? `?${qs}` : ''}`)
}

export async function approveEmployee(id: number): Promise<Employee> {
  return request<Employee>(`/employees/${id}/approve`, { method: 'POST' })
}

export async function rejectEmployee(id: number): Promise<Employee> {
  return request<Employee>(`/employees/${id}/reject`, { method: 'POST' })
}

export async function updateEmployee(id: number, data: EmployeeUpdateRequest): Promise<Employee> {
  return request<Employee>(`/employees/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}

export async function deleteEmployee(id: number): Promise<void> {
  return request(`/employees/${id}`, { method: 'DELETE' })
}

export async function resetEmployeePassword(id: number): Promise<ResetPasswordResponse> {
  return request<ResetPasswordResponse>(`/employees/${id}/reset-password`, { method: 'POST' })
}

export async function resetEmployeeFace(id: number): Promise<{ message: string }> {
  return request(`/employees/${id}/reset-face`, { method: 'POST' })
}

export async function createEmployee(data: EmployeeCreateRequest): Promise<Employee> {
  return request<Employee>('/employees/create', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
