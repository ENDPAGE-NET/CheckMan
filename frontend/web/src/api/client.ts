const BASE_URL = '/api'

export class ApiError extends Error {
  status: number

  constructor(status: number, message: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
  }
}

function getToken(): string | null {
  return localStorage.getItem('token')
}

export function clearToken(): void {
  localStorage.removeItem('token')
}

export async function request<T>(
  path: string,
  options?: RequestInit,
): Promise<T> {
  const token = getToken()
  const headers: Record<string, string> = {
    ...(options?.headers as Record<string, string>),
  }

  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  if (options?.body && typeof options.body === 'string') {
    headers['Content-Type'] = 'application/json'
  }

  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers,
  })

  if (res.status === 401) {
    clearToken()
    window.location.href = '/login'
    throw new ApiError(401, 'Unauthorized')
  }

  if (res.status === 204) {
    return undefined as T
  }

  if (!res.ok) {
    const error = await res.json().catch(() => ({}))
    throw new ApiError(res.status, error.detail || 'Request failed')
  }

  return res.json()
}
