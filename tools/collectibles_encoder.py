import json
import sys


w, h = 18, 16;
rooms = [[None for x in range(w)] for y in range(h)]


def encode(room_json):
    out = "DB "

    collectible_count = 0

    if len(room_json) > 7:
        print("error: too many collectibles assigned to room.")
        sys.exit(1)

    for collectible in room_json["collectibles"]:
        collectible_count += 1
        # TODO
        coords = collectible["x"]
        coords |= (collectible["y"]) << 4
        out += '${0:0{1}X}, '.format(coords, 2)
        out += '${0:0{1}X}, '.format(collectible["type"], 2)


    for i in range(collectible_count, 7):
        out += '${0:0{1}X}, '.format(0, 2)
        out += '${0:0{1}X}, '.format(0, 2)

    rooms[room_json["y"]][room_json["x"]] = out


with open(sys.argv[1]) as map_json:
    data = json.load(map_json)
    for room in data:
        encode(room)


null_room = "DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, "


for row in rooms:
    for cell in row:
        if cell:
            print(cell)
        else:
            print(null_room)
