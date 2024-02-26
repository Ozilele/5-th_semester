import matplotlib.pyplot as plt
import numpy as np


data = np.loadtxt('./testing2.txt')

x = data[:, 0]
y = data[:, 1]

plt.plot(x, y, marker='o', linestyle='-', color='r')
plt.xlabel('Dlugość listy tabu')
plt.ylabel('Średnia waga heurystyki')
plt.title('Wplyw dlugosci listy tabu na średni wynik heurystyki\n xqf131.tsp, maxIterations = 0.2')
# plt.title('Wplyw parametru poczatkowej temperatury na średni wynik heurystyki\n xqg237.tsp, \u03B2 = 0.95, epochs=0.25, iterat=0.2')
plt.show()