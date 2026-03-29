// frontend/web/src/components/LocationPickerMap.tsx

import { useRef, useEffect, useState } from 'react'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import markerIconUrl from 'leaflet/dist/images/marker-icon.png'
import markerIcon2xUrl from 'leaflet/dist/images/marker-icon-2x.png'
import markerShadowUrl from 'leaflet/dist/images/marker-shadow.png'
import { searchNominatim, type NominatimResult } from '../utils/nominatim'
import { useBreakpoint, isMobile } from '../hooks/useBreakpoint'
import styles from './LocationPickerMap.module.css'

// Fix Leaflet default marker icon in Vite bundler
L.Marker.prototype.options.icon = L.icon({
  iconUrl: markerIconUrl,
  iconRetinaUrl: markerIcon2xUrl,
  shadowUrl: markerShadowUrl,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
})

const DEFAULT_CENTER: L.LatLngTuple = [35.86, 104.19]
const DEFAULT_ZOOM = 5
const SELECTED_ZOOM = 15

interface Props {
  /** 初始标记位置，null 则显示中国全貌 */
  initialPosition?: { lat: number; lng: number } | null
  /** 打卡半径（米），用于绘制圆圈 */
  radiusMeters: number
  /** 位置变更回调 */
  onPositionChanged: (lat: number, lng: number) => void
}

export default function LocationPickerMap({ initialPosition, radiusMeters, onPositionChanged }: Props) {
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  const mapElRef = useRef<HTMLDivElement>(null)
  const mapRef = useRef<L.Map | null>(null)
  const markerRef = useRef<L.Marker | null>(null)
  const circleRef = useRef<L.Circle | null>(null)

  // Refs to avoid stale closures in Leaflet event handlers
  const radiusRef = useRef(radiusMeters)
  const onChangeRef = useRef(onPositionChanged)
  radiusRef.current = radiusMeters
  onChangeRef.current = onPositionChanged

  const [selected, setSelected] = useState<{ lat: number; lng: number } | null>(
    initialPosition ?? null,
  )
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<NominatimResult[]>([])
  const [searching, setSearching] = useState(false)
  const timerRef = useRef<ReturnType<typeof setTimeout>>(undefined)

  // Place or move marker + circle on map
  const placeMarker = (map: L.Map, lat: number, lng: number) => {
    if (markerRef.current) {
      markerRef.current.setLatLng([lat, lng])
    } else {
      markerRef.current = L.marker([lat, lng]).addTo(map)
    }
    if (circleRef.current) {
      circleRef.current.setLatLng([lat, lng])
    } else {
      circleRef.current = L.circle([lat, lng], {
        radius: radiusRef.current,
        color: 'rgba(85, 98, 87, 0.6)',
        fillColor: 'rgba(85, 98, 87, 0.10)',
        fillOpacity: 1,
        weight: 2,
      }).addTo(map)
    }
  }

  // Initialize Leaflet map
  useEffect(() => {
    if (!mapElRef.current || mapRef.current) return

    const center: L.LatLngTuple = initialPosition
      ? [initialPosition.lat, initialPosition.lng]
      : DEFAULT_CENTER
    const zoom = initialPosition ? SELECTED_ZOOM : DEFAULT_ZOOM

    const map = L.map(mapElRef.current).setView(center, zoom)
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map)

    map.on('click', (e: L.LeafletMouseEvent) => {
      const { lat, lng } = e.latlng
      setSelected({ lat, lng })
      placeMarker(map, lat, lng)
      onChangeRef.current(lat, lng)
    })

    mapRef.current = map

    if (initialPosition) {
      placeMarker(map, initialPosition.lat, initialPosition.lng)
    }

    // Fix tile rendering when map is inside a Modal (container may not be visible on init)
    setTimeout(() => map.invalidateSize(), 300)

    return () => {
      map.remove()
      mapRef.current = null
      markerRef.current = null
      circleRef.current = null
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  // Update circle radius reactively when parent changes radiusMeters
  useEffect(() => {
    circleRef.current?.setRadius(radiusMeters)
  }, [radiusMeters])

  // Debounced Nominatim search
  const handleSearchChange = (value: string) => {
    setQuery(value)
    if (timerRef.current) clearTimeout(timerRef.current)
    if (value.trim().length < 2) {
      setResults([])
      return
    }
    timerRef.current = setTimeout(async () => {
      setSearching(true)
      try {
        setResults(await searchNominatim(value.trim()))
      } finally {
        setSearching(false)
      }
    }, 500)
  }

  // Search result selected — fly to position
  const handleResultSelect = (r: NominatimResult) => {
    setSelected({ lat: r.lat, lng: r.lng })
    setResults([])
    setQuery('')
    const map = mapRef.current
    if (map) {
      placeMarker(map, r.lat, r.lng)
      map.flyTo([r.lat, r.lng], SELECTED_ZOOM)
    }
    onChangeRef.current(r.lat, r.lng)
  }

  return (
    <div className={styles.container}>
      {/* 搜索框 */}
      <div className={styles.searchWrapper}>
        <span className={styles.searchIcon}>🔍</span>
        <input
          className={styles.searchInput}
          placeholder="搜索地址..."
          value={query}
          onChange={(e) => handleSearchChange(e.target.value)}
        />
        {searching && <span className={styles.searchSpinner} />}
        {query && !searching && (
          <button className={styles.searchClear} onClick={() => { setQuery(''); setResults([]) }}>
            ✕
          </button>
        )}
      </div>

      {/* 搜索结果下拉 */}
      {results.length > 0 && (
        <div className={styles.searchResults}>
          {results.map((r, i) => (
            <div key={i} className={styles.resultItem} onClick={() => handleResultSelect(r)}>
              📍 {r.displayName}
            </div>
          ))}
        </div>
      )}

      {/* 地图 */}
      <div ref={mapElRef} className={mobile ? styles.mapMobile : styles.map} />

      {/* 坐标信息 */}
      {selected && (
        <div className={styles.coordInfo}>
          纬度: {selected.lat.toFixed(6)} &nbsp;&nbsp; 经度: {selected.lng.toFixed(6)}
        </div>
      )}
    </div>
  )
}
