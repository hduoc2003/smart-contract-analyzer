FROM ubuntu:latest
LABEL image.author="ppppHHHuuuu"
EXPOSE 80

# Cài các package cần thiết
RUN apt-get update && apt-get install -y apache2 \
python3.10 \
python3-pip \
python3.10-venv \
curl \
nano \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/node-v18.17.0-linux-x64/bin:${PATH}"
RUN curl https://nodejs.org/dist/v18.17.0/node-v18.17.0-linux-x64.tar.gz | tar xzf - -C /opt/

WORKDIR /var/www/apache-flask

COPY . .

# install requirement for BE
RUN cd backend && pip install -r linux_requirements.txt \
# cài solc
&& python3 ./production/docker_build_script.py\
# cài venv cho mythril
&& cd tools && python3 -m venv mythril_venv && ./mythril_venv/bin/pip install mythril
# cấp quyền ghi cho BE
RUN chmod o+w /var/www

# Install FE
ARG SERVER_BASE_API
ARG SERVER_BASE_URL
ENV SERVER_BASE_API=${SERVER_BASE_API}
ENV SERVER_BASE_URL=${SERVER_BASE_URL}
RUN cd frontend && npm install && npm run build
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# config apache
COPY ./apache-flask.conf /etc/apache2/sites-available/apache-flask.conf
RUN a2dissite 000-default.conf
RUN a2ensite apache-flask.conf
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_wstunnel
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Khởi chạy container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
CMD "/usr/local/bin/entrypoint.sh"
