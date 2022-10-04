FROM python:3.7-slim

COPY requires.txt /app/

WORKDIR /app

RUN pip install --upgrade pip \
    &&  pip install --requirement requires.txt

COPY src/main.py /app

ENTRYPOINT [ "python" ]
CMD [ "main.py" ]
