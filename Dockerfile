FROM python:3.8-buster

COPY ./app /app
COPY requirements.txt /

RUN pip3 install -r requirements.txt

WORKDIR app

ENTRYPOINT ["python3", "astrologers.py"]