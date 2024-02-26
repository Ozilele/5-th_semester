import matplotlib.pyplot as plt
import numpy as np

punkty = [ (10,10), (11,10), (12,10), (15,13), (15,19), (5,25), (0,26), (0,27), (5,31), (5,37), (0,39), (5,43), (15,43), (15,37), (15,31), (18,29), (18,31), (18,33), (18,35), (18,37), (18,39), (18,41), (18,42), (18,44), (18,45), (28,47), (28,43), (28,40), (34,41), (34,38), (38,34), (41,35), (41,36), (41,34), (41,32), (48,27), (48,22), (56,25), (57,25), (64,22), (74,24), (74,20), (77,21), (84,24), (84,29), (84,34), (79,37), (78,35), (79,33), (78,32), (74,29), (74,35), (57,44), (51,45), (51,47), (61,47), (61,45), (71,47), (71,45), (74,39), (78,39), (80,41), (84,38), (107,27), (84,20), (81,17), (80,10), (79,10), (78,10), (84,6), (80,5), (74,6), (74,12), (74,16), (71,16), (71,13), (71,11), (63,6), (57,12), (48,6), (34,5), (25,9), (25,11), (25,15), (28,16), (33,15), (34,15), (35,17), (38,16), (38,20), (40,22), (41,23), (38,30), (35,31), (34,31), (33,31), (32,31), (33,29), (34,29), (34,26), (33,26), (32,26), (28,28), (28,30), (28,34), (25,29), (25,28), (25,26), (25,24), (25,23), (25,22), (28,20), (18,23), (18,25), (18,27), (15,25), (18,21), (18,19), (18,17), (18,15), (18,13), (18,11), (15,8), (12,5), (8,0), (2,0), (0,13), (5,19), (5,13), (5,8), (9,10), (10,10), ]

def czytaj(nazwa_pliku):
    try:
        with open(nazwa_pliku, 'r') as plik:
            zawartosc = []
            for i, linia in enumerate(plik, start=1):
                if i == 140:
                    break
                if i >= 9:
                    elementy = linia.strip().split(" ")
                    zawartosc.append(elementy)
            return zawartosc
    except FileNotFoundError:
        print("Plik nie istnieje")
    except Exception as e:
        print("Blad")

def main():
    nazwa_pliku = "./xqf131.tsp"
    # dane = czytaj(nazwa_pliku)
    # x = []
    # y = []

    # for linia in dane:
    #     x.append(linia[1])
    #     y.append(linia[2])

    # print(len(x))
    # print(len(y))

    mst_x, mst_y = zip(*punkty)

    plt.title("icw1483.tsp, MST=4015, AVG=4693")
    plt.ylabel("Y Coords")
    plt.xlabel("X Coords")
    plt.xlim()
    plt.ylim()
    # marker = 'o',
    plt.plot(mst_x, mst_y, color = 'blue', linestyle='-', markersize = '4')
    plt.show()


if __name__ == "__main__":
    main()