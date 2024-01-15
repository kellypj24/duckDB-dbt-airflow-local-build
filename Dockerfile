# Use an Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV AIRFLOW_HOME=/usr/local/airflow
# Setting Python version
ENV PYTHON_VERSION=3.8

# Install Python and other dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python${PYTHON_VERSION} \
        python3-pip \
        python3-venv \
        libpq-dev \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry's bin directory to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set up virtual environment using Poetry
RUN python3.8 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set up working directory
WORKDIR /usr/local/airflow

# Copy the pyproject.toml and poetry.lock (if you have one) to the container
COPY pyproject.toml poetry.lock* /usr/local/airflow/

# Install Python dependencies using Poetry
RUN poetry install --only main

# Set up directories and user for Airflow
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && mkdir -p ${AIRFLOW_HOME}/dags ${AIRFLOW_HOME}/logs ${AIRFLOW_HOME}/plugins \
    && chown -R airflow: ${AIRFLOW_HOME}

USER airflow

# Expose ports (Airflow webserver port)
EXPOSE 8080

# Copy your DAGs and dbt project (if needed)
# COPY ./dags ${AIRFLOW_HOME}/dags
# COPY ./dbt_project ${YOUR_DBT_PROJECT_DIRECTORY}

# Start Airflow webserver by default
CMD ["airflow", "webserver"]
