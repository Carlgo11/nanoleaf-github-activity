# Nanoleaf Github Activity <img src="https://res.cloudinary.com/dbsfyc1ry/image/upload/v1637969751/nanoleaf_pqdsm7.svg" height="32px">

GitHub Activity graph on Nanoleaf Canvas using the Nanoleaf LAN API.

## Installation

### Nanoleaf Canvas IP

Set the value of `NANOLEAF_HOST` in `.env` to the Canvas IP address and port. The IP address can be found from your DHCP server or by scanning your network with something like Nmap.

The default port for Nanoleaf canvas is `16021`.

### API Key

An API key is needed to control the Nanoleaf Canvas. To get your API key follow the instructions by Nanoleaf on [Postman #Add a user](https://documenter.getpostman.com/view/1559645/RW1gEcCH#2bee1873-aedb-4a8f-9353-035e2d9ad584).
When you've received your API key, set it as the value for `NANOLEAF_TOKEN`.

### Panel IDs

This program needs to know the order of your Canvas panels and their IDs.
To get your panel IDs follow the instructions on [Postman #Layout](https://documenter.getpostman.com/view/1559645/RW1gEcCH#3eef67f5-8793-415e-ab09-53e75a2586c4)
Add the panel IDs to `PANELS` in in reverse chronological order.

Example:
```SH
PANELS="1001 1002 1003 1004"
```

## Usage

```SH
docker run --env-file .env carlgo11/nanoleaf
```

## License

The project is licensed under GPLv3. See the full license in [LICENSE.md](LICENSE.md). 