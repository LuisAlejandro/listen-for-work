FROM dockershelf/latex:basic

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg dirmngr texlive-xetex && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["tail", "-f", "/dev/null"]
