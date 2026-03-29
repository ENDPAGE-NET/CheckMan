from app.services.check_service import resolve_requirements, is_within_radius


def test_resolve_no_policy_no_override():
    result = resolve_requirements(policy=None, override_face=None, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is False
    assert result["require_location"] is False


def test_resolve_policy_only():
    class FakePolicy:
        require_face = True
        require_location = True
        location_lat = 31.23
        location_lng = 121.47
        location_radius = 200.0

    result = resolve_requirements(policy=FakePolicy(), override_face=None, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is True
    assert result["require_location"] is True
    assert result["location_lat"] == 31.23


def test_resolve_override_disables_policy():
    class FakePolicy:
        require_face = True
        require_location = True
        location_lat = 31.23
        location_lng = 121.47
        location_radius = 200.0

    result = resolve_requirements(policy=FakePolicy(), override_face=False, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is False
    assert result["require_location"] is True


def test_is_within_radius_inside():
    assert is_within_radius(31.230, 121.470, 31.231, 121.470, 200) is True


def test_is_within_radius_outside():
    assert is_within_radius(31.0, 121.0, 32.0, 121.0, 200) is False
