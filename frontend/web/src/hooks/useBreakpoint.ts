import { useState, useEffect } from 'react'

type Breakpoint = 'xs' | 'sm' | 'md' | 'lg'

function getBreakpoint(width: number): Breakpoint {
  if (width < 576) return 'xs'
  if (width < 768) return 'sm'
  if (width < 992) return 'md'
  return 'lg'
}

export function useBreakpoint(): Breakpoint {
  const [bp, setBp] = useState<Breakpoint>(() => getBreakpoint(window.innerWidth))

  useEffect(() => {
    const handler = () => setBp(getBreakpoint(window.innerWidth))
    window.addEventListener('resize', handler)
    return () => window.removeEventListener('resize', handler)
  }, [])

  return bp
}

export function isMobile(bp: Breakpoint): boolean {
  return bp === 'xs' || bp === 'sm'
}
