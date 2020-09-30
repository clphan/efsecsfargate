FROM nginx:1.11.5
ADD startup.sh . 
RUN chmod +x startup.sh
CMD ["./startup.sh"]