from PIL import Image
import json
import sys


im = Image.new(mode="RGB", size=(256 * 18, 256 * 16))


tileset = Image.open("data/tiles.bmp")
tile_images = []

for i in range(0, 60):
    t = tileset.crop((i * 16, 0, i * 16 + 16, 16))
    tile_images.append(t)


room_template_dirs = [
    "__ERROR__",
    "data/map/d/",
    "data/map/u/",
    "data/map/du/",
    "data/map/r/",
    "data/map/dr/",
    "data/map/ur/",
    "data/map/dur/",
    "data/map/l/",
    "data/map/dl/",
    "data/map/ul/",
    "data/map/dul/",
    "data/map/rl/",
    "data/map/drl/",
    "data/map/url/",
    "data/map/durl/"
]


def write_room(room_json):
    connections = 0

    room_x = room_json["x"]
    room_y = room_json["y"]

    if room_json["connections"]["down"]:
        connections |= 1
    if room_json["connections"]["up"]:
        connections |= (1 << 1)
    if room_json["connections"]["right"]:
        connections |= (1 << 2)
    if room_json["connections"]["left"]:
        connections |= (1 << 3)

    templ = room_template_dirs[connections]
    with open(templ + str(room_json["variant"]) + ".json", "r") as room_tile_map:
        js_tile_map = json.load(room_tile_map)

        data_array = js_tile_map["layers"][0]["data"]
        for y in range(0, 16):
            for x in range(0, 16):
                index = y * 16 + x
                im.paste(tile_images[(data_array[index]) - 1], (room_x * 256 + x * 16, room_y * 256 + y * 16))

    for c in room_json["collectibles"]:
        im.paste(tile_images[c["type"]], (room_x * 256 + c["x"] * 16, room_y * 256 + c["y"] * 16))

    for e in room_json["entities"]:
        im.paste(tile_images[27], (room_x * 256 + e["x"] * 16, room_y * 256 + e["y"] * 16))



with open(sys.argv[1]) as map_json:
    data = json.load(map_json)
    for room in data:
        write_room(room)


im.save("preview.png")
