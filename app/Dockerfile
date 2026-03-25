FROM nginx:alpine 
COPY . /usr/share/nginx/html
RUN addgroup -S suleman_group && \
    adduser -S -G suleman_group suleman_user
RUN chown -R suleman_user:suleman_group /etc/nginx/conf.d /usr/share/nginx/html /var/cache/nginx /run
USER suleman_user
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]