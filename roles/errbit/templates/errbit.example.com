server {
  listen 80;
  server_name {{ errbit_domain }};
  rewrite https://$server_name$request_uri? permanent;
}

server {
  listen 443 ssl;
  server_name {{ errbit_domain }};
  ssl_certificate /etc/letsencrypt/live/{{ server_hostname }}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/{{ server_hostname }}/privkey.pem;

  access_log {{ errbit_dir }}/log/access.log;
  error_log {{ errbit_dir }}/log/error.log;

  root {{ errbit_dir }}/public/;
  index index.html;

  location / {
   proxy_pass http://127.0.0.1:8080;
   proxy_set_header X-Real-IP  $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header X-Forwarded-Proto https;
   proxy_set_header Host $http_host;
   proxy_redirect off;

   if (-f $request_filename/index.html) {
    rewrite (.*) $1/index.html break;
   }

   if (-f $request_filename.html) {
    rewrite (.*) $1.html break;
   }
  }
}
