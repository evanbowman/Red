import json
import sys


w, h = 18, 16;
rooms = [[None for x in range(w)] for y in range(h)]


def encode(room_json):
    out = "DB "
    connections = 0

    if room_json["connections"]["down"]:
        connections |= 1
    if room_json["connections"]["up"]:
        connections |= (1 << 1)
    if room_json["connections"]["right"]:
        connections |= (1 << 2)
    if room_json["connections"]["left"]:
        connections |= (1 << 3)

    out += '${0:0{1}X}, '.format(connections, 2)
    out += '${0:0{1}X}, '.format(room_json["variant"], 2)

    # Byte is reserved for future use.
    out += '${0:0{1}X}, '.format(255, 2)

    if len(room_json["entities"]) > 5:
        print("error: too many entities assigned to room.")
        sys.exit(1)

    entity_count = 0

    for entity in room_json["entities"]:
        out += '${0:0{1}X}, '.format(entity["type"], 2)
        coords = entity["x"]
        coords |= (entity["y"]) << 4
        out += '${0:0{1}X}, '.format(coords, 2)
        entity_count += 1

    for i in range(entity_count, 5):
        out += '${0:0{1}X}, '.format(0, 2)
        out += '${0:0{1}X}, '.format(0, 2)

    rooms[room_json["y"]][room_json["x"]] = out


with open(sys.argv[1]) as map_json:
    data = json.load(map_json)
    for room in data:
        encode(room)


null_room = "DB $00, $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, "


for row in rooms:
    for cell in row:
        if cell:
            print(cell)
        else:
            print(null_room)
