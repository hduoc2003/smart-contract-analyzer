FROM python:3.10.12
EXPOSE 5000
EXPOSE 80

# Thiết lập thư mục làm việc
WORKDIR /app

# Cài package cơ bản
RUN apt-get update && apt-get install -y \
curl \
nano \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/*

# Cấu hình Nginx
RUN apt update && apt install -y nginx
RUN rm /etc/nginx/nginx.conf
COPY ./nginx.conf /etc/nginx/
# RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/
RUN chown -R www-data:www-data /app
RUN chmod -R 755 /app

# Sao chép mã nguồn ứng dụng Flask vào container
COPY . .

# Config BE
# Cài package
RUN cd backend && pip install --no-cache-dir -r linux_requirements.txt \
# cài solc
&& python ./production/docker_build_script.py
# Cài mythril
RUN cd ./backend/tools && python -m venv mythril_venv && ./mythril_venv/bin/pip install mythril
# cấp quyền ghi cho BE
# RUN chmod o+w /var/www

# Install FE
ENV PATH="/opt/node-v18.17.0-linux-x64/bin:${PATH}"
RUN curl https://nodejs.org/dist/v18.17.0/node-v18.17.0-linux-x64.tar.gz | tar xzf - -C /opt/
ARG SERVER_BASE_API
ARG SERVER_BASE_URL
ENV SERVER_BASE_API=${SERVER_BASE_API}
ENV SERVER_BASE_URL=${SERVER_BASE_URL}
RUN cd frontend && \
npm install && \
npm run build && \
# Xoá tất cả trừ thư mục out
find . -mindepth 1 -maxdepth 1 ! -name 'out' -exec rm -rf {} \;

# Khởi chạy container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
CMD "/usr/local/bin/entrypoint.sh"
