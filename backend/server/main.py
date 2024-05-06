from fastapi import FastAPI, UploadFile, HTTPException, Form
from ultralytics import YOLO
from typing import Annotated
import os

app = FastAPI()

# env variable for the location of the
# model = YOLO(os.environ["MODEL_PATH"], task="detect")
model = YOLO("../model/model-ckpt.pt", task="detect") # uncomment this for pytest

@app.get("/")
async def root():
    return {"message": "Server running"}

@app.post("/predict/")
async def predict(
        image: UploadFile,
        iou: Annotated[float, Form()] = 0.2,
        conf: Annotated[float, Form()] = 0.45,
        imgsz: Annotated[int, Form()] = 1280,
):
    if image is None:
        raise HTTPException(status_code=400)
    elif image.filename.split(".")[-1] not in ['jpeg', 'png', 'jpg']:
        raise HTTPException(status_code=415, detail="File is not an image")

    try:
        contents = image.file.read()
        with open(image.filename, "wb") as f:
            f.write(contents)
    except Exception:
        return HTTPException(status_code=500, detail="Server Error")
    finally:
        image.file.close()

    result = model.predict(image.filename, imgsz=imgsz, conf=conf, iou=iou, save=True)
    total_pred = len(result[0].boxes)
    preds = result[0].boxes

    bboxes = preds.xyxy.tolist()
    classes = preds.cls.tolist()

    return {"predictions": total_pred, "bboxes": bboxes, "classes": classes}


