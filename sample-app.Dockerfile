# Use the official Nginx base image
FROM nginx:stable-alpine

# Copy the custom HTML page to the Nginx document root
COPY app/site/index.html /usr/share/nginx/html/

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
