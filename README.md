# AsciiSketch
## Table of contents
  * [Setup](#setup)
  * [Usage](#usage)
  * [Trade offs](#trade-offs)

## Setup
### Database

Using `docker-compose`:

```bash
docker-compose up -d
```

## Application

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

## Usage
### Client
A simple read-only client is available at http://localhost:4000/canvas/<:canvas_id>

### API

REST API is available at `http://localhost:4000/api/v1/canvas`

#### Creating a canvas

```bash
curl --request POST \
  --url http://localhost:4000/api/v1/canvas \
  --header 'Content-Type: application/json' \
  --data '{   
    "width": 21,
	"height": 8,
	"empty_character": " "
}'
```

All paramters are optional. Response:

`201 Created`

```json
{
  "id": "8cb3d418-d360-4ddf-8eae-d133202a8bda"
}
```

#### Fetching a canvas

```bash
curl --request GET \
  --url http://localhost:4000/api/v1/canvas/8cb3d418-d360-4ddf-8eae-d133202a8bda
```

Response:

`200 OK`

```json
{
  "canvas": "                     \n                     \n                     \n                     \n                     \n                     \n                     \n                     ",
  "height": 8,
  "id": "8cb3d418-d360-4ddf-8eae-d133202a8bda",
  "inserted_at": "2021-11-19T11:58:51",
  "updated_at": "2021-11-19T11:58:51",
  "width": 21
}{
  "id": "8cb3d418-d360-4ddf-8eae-d133202a8bda"
}
```

#### Drawing
##### Rectangle

```bash
curl --request PUT \
  --url http://localhost:4000/api/v1/canvas/8cb3d418-d360-4ddf-8eae-d133202a8bda/draw \
  --header 'Content-Type: application/json' \
  --data '{
	"change": "rectangle",
	"x": 1,
	"y": 2,
	"height": 5,
	"width": 7,
	"fill": "+",
	"outline": "X"
}'
```

All params are required, except for `fill` and `outline` (only either one of these is required). Response:

`200 OK`

```json
{
  "meta": {
    "time_ms": 16
  }
}
```

##### Flood fill

```bash
curl --request PUT \
  --url http://localhost:4000/api/v1/canvas/8cb3d418-d360-4ddf-8eae-d133202a8bda/draw \
  --header 'Content-Type: application/json' \
  --data '{
	"change": "flood_fill",
	"x": 0,
	"y": 0,
	"character": "-"
}'
```

All params are required. Response:

`200 OK`

```json
{
  "meta": {
    "time_ms": 16
  }
}
```

## Trade offs

Due to time constraints there are some areas, that need improvements:
  * **tests** - there aren't any for the REST API and client
  * **web side of the project** - in general both the REST API and client are quite raw. If this application was to be developed further, these part could be improved by i.e. extracting some common helpers, creating fallback views etc.
  * **performance** - it's fine for small canvases, but the bigger they get, the more performance suffers. For example: flood fill takes around 80ms on an empty 130x80 canvas, 200ms on a 150x150 canvas and around 7 seconds on a 500x500 one. If there was a requirement to handle bigger canvases, this issue would have to be addressed by implementing more efficient algorithms and potentially different data structures.
    
    