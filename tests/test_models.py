"""
Unit tests for OpenMS language primitive models
"""

import pytest
from openms.models import (
    OpenMSError, OMSBox, OMSBall, OMSHouse, OMSGame, OMSPhoto, OMSBody2D, OMSBody3D
)


def test_oms_box():
    box = OMSBox(size=120, color="#ff0000")
    assert box.size == 120
    assert box.color == "#ff0000"
    assert box.kind == "box"
    assert "120" in repr(box)


def test_oms_ball():
    ball = OMSBall(radius=40, color="#00ff00")
    assert ball.radius == 40
    assert ball.color == "#00ff00"
    assert ball.kind == "bol"
    assert "40" in repr(ball)


def test_oms_house():
    house = OMSHouse(width=300, height=250)
    assert house.width == 300
    assert house.height == 250
    assert house.kind == "house"


def test_oms_game():
    game = OMSGame(title="My Adventure", width=800, height=600)
    box = OMSBox(100)
    game.add(box)
    assert game.title == "My Adventure"
    assert len(game.objects) == 1
    assert game.objects[0] == box


def test_oms_photo():
    photo = OMSPhoto("/path/to/img.png")
    assert photo.path == "/path/to/img.png"
    assert photo.kind == "photo"


def test_oms_body_wrappers():
    box = OMSBox(50)
    b2d = OMSBody2D(box)
    b3d = OMSBody3D(box)
    assert b2d.source == box
    assert b3d.source == box
    assert b2d.kind == "boody_2D"
    assert b3d.kind == "boody_3D"


def test_openms_error():
    err = OpenMSError("Language error")
    assert str(err) == "Language error"
