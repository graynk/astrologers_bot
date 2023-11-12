FROM python:3.11-buster

RUN apt-get update && apt-get install libraqm0 -y
COPY requirements.txt /
RUN pip3 install -r requirements.txt
COPY ./app /app

WORKDIR app

ENTRYPOINT ["python3", "astrologers.py"]