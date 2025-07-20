# Use Node.js 20.x as the base image
FROM node:20-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the frontend application
RUN npm run build

# Use nginx to serve the built frontend
FROM nginx:alpine

# Copy the built frontend from the previous stage
COPY --from=0 /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000 (as configured in nginx.conf)
EXPOSE 3000

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
