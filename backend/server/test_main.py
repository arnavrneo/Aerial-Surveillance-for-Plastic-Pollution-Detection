from fastapi.testclient import TestClient
from .main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Server running"}


def test_predict_empty():
    data = {"image": (None, None)}  # empty input
    response = client.post(
        "/predict/",
        data=data,
        headers={"Content-Type": "multipart/form-data"},  # write the correct headers here
    )
    assert response.status_code == 400