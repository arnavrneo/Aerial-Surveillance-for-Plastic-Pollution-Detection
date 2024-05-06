import streamlit as st
from components import authenticate as at
import requests
import os
import cv2
import numpy as np
from streamlit_image_comparison import image_comparison

st.header("Aerial Surveillance for Plastic Pollution Detection")

# for checking the authentication
at.set_st_state_vars()

# login/logout button
if st.session_state["authenticated"]:
    with st.sidebar:
        at.button_logout()
        
        # inputs -> image, iou, conf, imgsz
        uploaded_image = st.file_uploader("Choose the image", type=["png", "jpg", "jpeg"])
                
        iou = st.slider("Intersection-Over-Union value", 0.0, 1.0, 0.2)
        conf = st.slider("Confidence value", 0.0, 1.0, 0.4)
        imgsz = st.radio(
            "Image Size (px) [x,x]",
            [640, 1280, 2560],
            index=None,
            horizontal=True
        )

    headers = {
        'accept': 'application/json',
    }

    _, col1, _ = st.columns([1, 1, 1])

    if col1.button('Check Server', use_container_width=True):
        response = requests.get(os.getenv("BACKEND_URI"), headers=headers)
        res = response.json()["message"]
        st.success(res, icon="✅")

    _, col2, _ = st.columns([1, 1, 1])

    if uploaded_image:
        if col2.button('Perform Detection', use_container_width=True):
            files = {
                'image': (uploaded_image.name, uploaded_image.getvalue(), 'image/jpeg'),
                'iou': (None, str(iou).encode()),
                'conf': (None, str(conf).encode()),
                'imgsz': (None, imgsz),
            }

            response = requests.post(os.getenv("BACKEND_URI") + '/predict/', headers=headers, files=files)
            prediction_count = response.json()["predictions"]

            col1, col2 = st.columns([1, 1])
            col1.header("No of predictions: ")
            col2.subheader(prediction_count)

            st.divider()
            image_np = np.frombuffer(uploaded_image.getvalue(), dtype=np.uint8)
            image_before = cv2.imdecode(image_np, cv2.IMREAD_COLOR)
            image_after = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

            for bbox in response.json()["bboxes"]:
                x_min, y_min, x_max, y_max = bbox
                cv2.rectangle(image_after, (int(x_min), int(y_min)), (int(x_max), int(y_max)), (0, 255, 0), 2)
                cv2.putText(image_after, 'PLASTIC', (int(x_min), int(y_min) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36, 255, 12), 2)

            image_comparison(
                img1=image_before,
                label1="Before Detection",
                img2=image_after,
                label2="After Detection",
                show_labels=True,
                make_responsive=True
            )

else:
    at.button_login()
