FROM dockershelf/latex:basic

LABEL listen-for-work.poppler=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg dirmngr texlive-xetex poppler-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["tail", "-f", "/dev/null"]
