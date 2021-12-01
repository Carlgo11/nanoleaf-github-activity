# Nanoleaf Github Activity <img src="https://res.cloudinary.com/dbsfyc1ry/image/upload/v1637969751/nanoleaf_pqdsm7.svg" height="32px">

GitHub Activity graph on Nanoleaf Canvas using the Nanoleaf LAN API.

## Installation

[![](https://img.shields.io/docker/image-size/carlgo11/nanoleaf-github-activity?label=Docker&logo=Docker&sort=semver&style=for-the-badge)](https://hub.docker.com/r/carlgo11/nanoleaf-github-activity)
[![](https://img.shields.io/docker/image-size/carlgo11/nanoleaf-github-activity?color=3fb930&label=GitHub&logo=GitHub&sort=semver&style=for-the-badge)](https://github.com/Carlgo11/nanoleaf-github-activity/pkgs/container/nanoleaf-github-activity)

### Environment Variables

|      Name      |                       Description                       |        Example        |
|:--------------:|:-------------------------------------------------------:|:---------------------:|
|  GITHUB_USER   |                     GitHub Username                     |      "Carlgo11"       |
| NANOLEAF_HOST  |              LAN IP of the Nanoleaf Canvas              |     "192.168.1.2"     |
| NANOLEAF_PORT  |       Optional Nanleaf API port. Default is 16021       |        "16021"        |
| NANOLEAF_TOKEN |           Nanoleaf [API Key][postman_api_key]           ||
|     PANELS     | List of Canvas panel IDs in reverse chronological order | "1001 1002 1003 1004" |

## Usage

### Docker

```SHELL
docker run --env-file .env carlgo11/nanoleaf
```

### Docker Compose

```YAML
version: '3.7'
services:
  nanoleaf:
    image: carlgo11/nanoleaf-github-activity
    env_file:
      - .env
```

## License

The project is licensed under GPLv3. See the full license in [LICENSE.md](LICENSE.md).

[postman_api_key]: https://documenter.getpostman.com/view/1559645/RW1gEcCH#2bee1873-aedb-4a8f-9353-035e2d9ad584