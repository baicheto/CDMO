# Use the official Minizinc image as the base
FROM minizinc/minizinc:latest

# Set the working directory in the container
WORKDIR /src

# Copy the current directory contents into the container at /src
COPY . .

RUN apt-get update \
 && apt-get install -y python3 python3-venv python3-pip

# Update the package lists and install necessary packages
RUN python3 -m venv venv \
 && . venv/bin/activate \
 && pip install --no-cache-dir -r requirements.txt

ENV PATH="/src/venv/bin:$PATH"

# Set the default command to use the virtual environment
CMD ["python", "/src/run_instances.py"]
