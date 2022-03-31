FROM python:3.9-bullseye as intermediate
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    PATH="/root/.cargo/bin:/root/.poetry/bin:$PATH"
RUN apt update \
    && mkdir /root/.ssh/ \
    && echo "StrictHostKeyChecking no">> /root/.ssh/id_rsa \
    && echo "UserKnownHostsFile /dev/null">> /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan git.git.com >> /root/.ssh/known_hosts \
    && chmod 600 /root/.ssh/known_hosts
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
WORKDIR /app
COPY poetry.lock pyproject.toml ./
RUN poetry install --no-dev -E prod

FROM python:3.9-bullseye
RUN apt update
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH="${PYTHONPATH}:/app" \
ENV PATH="/app/.venv/bin:$PATH"
COPY --from=intermediate /app/.venv/ /app/.venv
COPY provider /app/provider
COPY ./entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh
WORKDIR /app
VOLUME ["/var/logs"]
EXPOSE 5555
ENTRYPOINT [ "/app/entrypoint.sh" ]


