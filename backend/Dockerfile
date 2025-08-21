# Use a lightweight version of Python
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Now, copy the rest of your application code
COPY . .

# Expose the port the application will run on
EXPOSE 5000

# The command to start your Flask server
CMD ["python", "app.py"]
