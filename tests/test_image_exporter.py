"""Unit tests for Image to EXE exporter module."""

import os
import tempfile
import pytest
from app.image_exporter.generator import ImageExeExporter, generate_viewer_script, SUPPORTED_IMAGE_EXTENSIONS


def test_supported_image_extensions():
    assert ".png" in SUPPORTED_IMAGE_EXTENSIONS
    assert ".jpg" in SUPPORTED_IMAGE_EXTENSIONS
    assert ".webp" in SUPPORTED_IMAGE_EXTENSIONS


def test_image_validation():
    exporter = ImageExeExporter()

    with tempfile.NamedTemporaryFile(suffix=".png") as tmp_img:
        tmp_img.write(b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01")
        tmp_img.flush()

        res = exporter.validate_image_path(tmp_img.name)
        assert res["valid"] is True
        assert res["extension"] == ".png"
        assert res["size_bytes"] > 0

    with tempfile.NamedTemporaryFile(suffix=".txt") as tmp_txt:
        res_txt = exporter.validate_image_path(tmp_txt.name)
        assert res_txt["valid"] is False
        assert "Unsupported image format" in res_txt["error"]


def test_generate_viewer_script():
    script = generate_viewer_script("sample_photo.jpg")
    assert "resource_path(\"sample_photo.jpg\")" in script
    assert "class ImageViewer" in script
    assert "tk.Tk" in script
