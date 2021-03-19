import csv

with open('test2.csv') as csvfile:
    reader = csv.reader(csvfile)

    for row in reader:
        print('DB', end=' ')

        first = True

        for num in row:
            if not first:
                print('', end=', ')

            first = False

            if int(num) < 16:
                print('$0', end='')
                print(hex(int(num))[2:], end='')
            else:
                print('$', end='')
                print(hex(int(num))[2:], end='')


        print("")
