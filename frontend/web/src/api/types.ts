export interface LoginRequest {
  username: string
  password: string
}

export interface AdminLoginResponse {
  access_token: string
  token_type: string
  must_change_password: boolean
  username: string
  is_super: boolean
}

export interface ChangePasswordRequest {
  old_password: string
  new_password: string
}

export type EmployeeStatus = 'pending' | 'active' | 'rejected'

export interface Employee {
  id: number
  name: string
  username: string
  status: EmployeeStatus
  face_registered: boolean
  must_change_password: boolean
  policy_id: number | null
  override_face: boolean | null
  override_location: boolean | null
  override_lat: number | null
  override_lng: number | null
  override_radius: number | null
  created_at: string
}

export interface EmployeeUpdateRequest {
  name?: string
  policy_id?: number | null
  override_face?: boolean | null
  override_location?: boolean | null
  override_lat?: number | null
  override_lng?: number | null
  override_radius?: number | null
}

export interface ResetPasswordResponse {
  message: string
  temp_password: string
}

export interface Policy {
  id: number
  name: string
  require_face: boolean
  require_location: boolean
  location_lat: number | null
  location_lng: number | null
  location_radius: number | null
  created_at: string
}

export interface PolicyCreateRequest {
  name: string
  require_face?: boolean
  require_location?: boolean
  location_lat?: number | null
  location_lng?: number | null
  location_radius?: number | null
}

export interface PolicyUpdateRequest {
  name?: string
  require_face?: boolean
  require_location?: boolean
  location_lat?: number | null
  location_lng?: number | null
  location_radius?: number | null
}

export interface AdminUser {
  id: number
  username: string
  is_super: boolean
  must_change_password: boolean
  created_at: string
}

export interface AdminCreateRequest {
  username: string
  password: string
  is_super?: boolean
}

export interface EmployeeCreateRequest {
  name: string
  username: string
  password: string
  policy_id?: number | null
}

export type CheckType = 'clock_in' | 'clock_out'

export interface CheckRecord {
  id: number
  employee_id: number
  check_time: string
  check_type: CheckType
  face_passed: boolean | null
  location_lat: number | null
  location_lng: number | null
  location_passed: boolean | null
  created_at: string
}
