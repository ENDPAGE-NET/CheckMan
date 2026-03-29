import math


def resolve_requirements(
    policy,
    override_face, override_location,
    override_lat, override_lng, override_radius,
) -> dict:
    require_face = False
    require_location = False
    location_lat = None
    location_lng = None
    location_radius = None

    if policy is not None:
        require_face = policy.require_face
        require_location = policy.require_location
        location_lat = policy.location_lat
        location_lng = policy.location_lng
        location_radius = policy.location_radius

    if override_face is not None:
        require_face = override_face
    if override_location is not None:
        require_location = override_location
    if override_lat is not None:
        location_lat = override_lat
    if override_lng is not None:
        location_lng = override_lng
    if override_radius is not None:
        location_radius = override_radius

    return {
        "require_face": require_face,
        "require_location": require_location,
        "location_lat": location_lat,
        "location_lng": location_lng,
        "location_radius": location_radius,
    }


def is_within_radius(target_lat, target_lng, actual_lat, actual_lng, radius_meters) -> bool:
    R = 6371000
    lat1 = math.radians(target_lat)
    lat2 = math.radians(actual_lat)
    dlat = math.radians(actual_lat - target_lat)
    dlng = math.radians(actual_lng - target_lng)

    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c

    return distance <= radius_meters
