from app.core.config import settings
from app.services.face_service import encode_and_save_face, load_face_encoding, compare_faces, delete_face


def test_encode_and_save_face():
    result = encode_and_save_face(9999, b"fake image bytes")
    assert result is True
    face_path = settings.FACE_DATA_DIR / "9999.pkl"
    assert face_path.exists()
    face_path.unlink()


def test_load_face_encoding_not_found():
    result = load_face_encoding(99999)
    assert result is None


def test_compare_faces():
    result = compare_faces("known", b"face bytes")
    assert result is True


def test_delete_face_nonexistent():
    delete_face(99999)
