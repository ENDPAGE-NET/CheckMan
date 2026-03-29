from app.core.security import hash_password, verify_password, create_access_token, decode_access_token


def test_password_hash_and_verify():
    password = "testpass123"
    hashed = hash_password(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("wrong", hashed) is False


def test_create_and_decode_token():
    token = create_access_token(subject_id=1, role="employee")
    payload = decode_access_token(token)
    assert payload["sub"] == "1"
    assert payload["role"] == "employee"


def test_decode_invalid_token():
    payload = decode_access_token("invalid.token.here")
    assert payload is None
