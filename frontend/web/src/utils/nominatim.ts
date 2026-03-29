// frontend/web/src/utils/nominatim.ts

export interface NominatimResult {
  displayName: string
  lat: number
  lng: number
}

/**
 * 调用 Nominatim API 搜索地址，返回最多 5 条结果。
 * 失败时返回空数组，不抛出异常。
 */
export async function searchNominatim(query: string): Promise<NominatimResult[]> {
  try {
    const params = new URLSearchParams({
      q: query,
      format: 'json',
      limit: '5',
      'accept-language': 'zh',
    })
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?${params}`,
      { headers: { 'User-Agent': 'CheckManAdmin/1.0' } },
    )
    if (!response.ok) return []
    const data = await response.json()
    return (data as Array<Record<string, string>>).map((item) => ({
      displayName: item.display_name,
      lat: parseFloat(item.lat),
      lng: parseFloat(item.lon),
    }))
  } catch {
    return []
  }
}
