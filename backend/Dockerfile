# Use Node.js 20.x as the base image
FROM node:20-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the application code
COPY . .

# Expose port 4000 in the container
EXPOSE 4000

# Start the backend application
CMD ["npm", "start"]
