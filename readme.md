# Lampberrypi (仮)

## Abstract

Raspberry Pi OS + Apache + PHP(fpm) + MariaDB の開発環境を Docker に構築する Docker Compose 等の設定集です。

## Usage

`git clone https://github.com/arm-band/docker-compose-lampberrypi.git`

### Usage

1. copy `sample.env` and rename `.env`
2. change parameters in `.env`
3. `docker-compose up -d`
4. `docker-compose exec web /bin/bash`

### Finish

1. `docker-compose down`

---

以上