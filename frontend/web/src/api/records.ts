import { request } from './client'
import type { CheckRecord } from './types'

export async function listRecords(params?: {
  employee_id?: number
  start_date?: string
  end_date?: string
}): Promise<CheckRecord[]> {
  const query = new URLSearchParams()
  if (params?.employee_id) query.set('employee_id', String(params.employee_id))
  if (params?.start_date) query.set('start_date', params.start_date)
  if (params?.end_date) query.set('end_date', params.end_date)
  const qs = query.toString()
  return request<CheckRecord[]>(`/records${qs ? `?${qs}` : ''}`)
}
