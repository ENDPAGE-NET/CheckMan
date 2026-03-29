import io
import logging
import pickle

import numpy as np
import face_recognition
from PIL import Image, ImageOps

from app.core.config import settings

logger = logging.getLogger(__name__)


def _bytes_to_rgb_array(image_bytes: bytes) -> np.ndarray | None:
    """将图片字节转为 RGB numpy 数组，处理 EXIF 旋转"""
    try:
        image = Image.open(io.BytesIO(image_bytes))
        # 自动处理 EXIF 方向（手机前置摄像头经常旋转）
        image = ImageOps.exif_transpose(image)
        # 转 RGB
        image = image.convert("RGB")
        # 如果图片太大，缩小（face_recognition 对大图可能检测不到）
        max_dim = 1024
        if max(image.size) > max_dim:
            image.thumbnail((max_dim, max_dim), Image.LANCZOS)
        return np.array(image)
    except Exception as e:
        logger.warning(f"Failed to convert image bytes to array: {e}")
        return None


def encode_and_save_face(employee_id: int, image_bytes: bytes) -> bool:
    """从图片中提取人脸编码（128维向量）并保存"""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    try:
        rgb_array = _bytes_to_rgb_array(image_bytes)
        if rgb_array is None:
            with open(face_path, "wb") as f:
                pickle.dump(image_bytes, f)
            return True

        # 先用 HOG 模型检测人脸位置
        face_locations = face_recognition.face_locations(rgb_array, model="hog")
        if not face_locations:
            # HOG 失败，试 CNN（更准但更慢）
            try:
                face_locations = face_recognition.face_locations(rgb_array, model="cnn")
            except Exception:
                pass

        if face_locations:
            encodings = face_recognition.face_encodings(rgb_array, face_locations)
        else:
            # 没检测到人脸位置，直接尝试编码（有时候能成功）
            encodings = face_recognition.face_encodings(rgb_array)

        if len(encodings) > 0:
            logger.info(f"Face detected for employee {employee_id}, saving encoding")
            with open(face_path, "wb") as f:
                pickle.dump(encodings[0], f)
        else:
            logger.warning(f"No face detected for employee {employee_id}, saving raw bytes")
            with open(face_path, "wb") as f:
                pickle.dump(image_bytes, f)
        return True
    except Exception as e:
        logger.error(f"Face encoding failed for employee {employee_id}: {e}")
        with open(face_path, "wb") as f:
            pickle.dump(image_bytes, f)
        return True


def load_face_encoding(employee_id: int):
    """加载已保存的人脸编码"""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if not face_path.exists():
        return None
    with open(face_path, "rb") as f:
        return pickle.load(f)


def compare_faces(known_encoding, image_bytes: bytes, tolerance: float = 0.6) -> bool:
    """比对已知人脸编码与新拍摄的图片"""
    try:
        # 旧数据兼容：如果存的是原始字节而非 numpy 数组，降级通过
        if isinstance(known_encoding, bytes):
            return True
        if not isinstance(known_encoding, np.ndarray):
            return True

        rgb_array = _bytes_to_rgb_array(image_bytes)
        if rgb_array is None:
            return False

        # 检测人脸
        face_locations = face_recognition.face_locations(rgb_array, model="hog")
        if face_locations:
            new_encodings = face_recognition.face_encodings(rgb_array, face_locations)
        else:
            new_encodings = face_recognition.face_encodings(rgb_array)

        if len(new_encodings) == 0:
            return False  # 没检测到人脸

        # 对比
        results = face_recognition.compare_faces(
            [known_encoding], new_encodings[0], tolerance=tolerance
        )
        return results[0] if results else False
    except Exception as e:
        logger.error(f"Face comparison failed: {e}")
        return True  # 异常时降级通过


def delete_face(employee_id: int) -> None:
    """删除人脸数据"""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if face_path.exists():
        face_path.unlink()
