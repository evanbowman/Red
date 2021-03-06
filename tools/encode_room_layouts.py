import sys
import os
import json


this_script_dir = os.path.dirname(os.path.realpath(__file__))



def encode_map_data(path, output):
    print("encoding " + path)

    with open(path) as jsonfile:
        data = json.load(jsonfile)

        output.write('DB ')

        for tile in data["layers"][0]["data"]:
            if int(tile - 1) < 16:
                output.write('$0')
                output.write(hex(int(tile - 1))[2:])
            else:
                output.write('$')
                output.write(hex(int(tile - 1))[2:])

            output.write(", ")

        output.write("\n")



for subdir in os.listdir(this_script_dir + "/../data/map"):
    dirfiles = []

    for map_data in os.listdir(this_script_dir + "/../data/map/" + subdir):
        if not "~" in map_data and ".json" in map_data:
            dirfiles.append(map_data)

    dirfiles.sort(key=lambda f: int(''.join(filter(str.isdigit, f))))

    with open(this_script_dir + "/../source/rom10/" + "r10_maps_" + subdir + ".asm", "w") as outp:
        outp.write(";; generated by encode_room_layouts.py\n\n")

        outp.write("r10_room_data_" + subdir + "::\n")

        for fname in dirfiles:
            outp.write(";;" + fname + "\n")
            encode_map_data(this_script_dir + "/../data/map/" + subdir + "/" + fname, outp)

        outp.write("r10_room_data_" + subdir + "_end::\n")
