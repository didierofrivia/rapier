# o-∫)--rapier---

## An [APIcast](https://github.com/3scale/apicast) UI MGMT Tool
APIcast is an API gateway built on top of [NGINX](https://www.nginx.com/). It is
part of the [Red Hat 3scale API Management
Platform](https://www.redhat.com/en/technologies/jboss-middleware/3scale).


## Getting started

### Dependencies
* [Node](https://nodejs.org/en/download/)
* [Elm](https://guide.elm-lang.org/install.html)

### Development
Right now it's not wired up to APIcast directly, so it works with a
"fake" backend that manages the writing of the config file.
This is a development choice before wiring up everything together to ease
the crafting of the schema.

#### Install dependencies
```shell
npm install
```

#### Run the project
```shell
API_URL=//localhost PORT=3000 npm run dev
```
Note: You might want to add the envs to your .env

Now visit http://localhost:8080

You might also want to run the "client" and "server" separately

```shell
npm run dev:server
npm run dev:client
```
Note: Take a look at the [package.json](/package.json) for the full
list of scripts

## License
[Apache 2.0](LICENSE)
