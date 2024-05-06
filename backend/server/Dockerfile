FROM python:3.9
LABEL authors="neo"

WORKDIR /app

COPY . /app

RUN apt-get update -y && apt-get install -y libgl1 && apt-get install -y libgl1-mesa-glx

RUN pip install --no-cache-dir --upgrade -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]