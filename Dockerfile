FROM python:3.8-buster

COPY ./ /

RUN pip3 install -r requirements.txt

ENTRYPOINT ["python3", "astrologers.py"]