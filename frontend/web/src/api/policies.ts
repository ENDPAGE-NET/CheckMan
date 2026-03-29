import { request } from './client'
import type { Policy, PolicyCreateRequest, PolicyUpdateRequest } from './types'

export async function listPolicies(): Promise<Policy[]> {
  return request<Policy[]>('/policies')
}

export async function createPolicy(data: PolicyCreateRequest): Promise<Policy> {
  return request<Policy>('/policies', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}

export async function updatePolicy(id: number, data: PolicyUpdateRequest): Promise<Policy> {
  return request<Policy>(`/policies/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}

export async function deletePolicy(id: number): Promise<void> {
  return request(`/policies/${id}`, { method: 'DELETE' })
}
