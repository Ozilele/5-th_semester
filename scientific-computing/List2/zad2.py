import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 60, 350)
y = np.exp(x) * np.log(1 + np.exp(-x))

# plt.figure(figsize=(8, 6))
plt.figure(figsize=(10,6))
plt.plot(x, y, label='$f(x) = e^x \ln(1 + e^{-x})$', color='g')
plt.title('Wykres funkcji $f(x) = e^x \ln(1 + e^{-x})$')
plt.xlabel('x')
plt.ylabel('f(x)')
# x_ticks = np.arange(-10, 11, 1)  # Etykiety co 1 jednostkę
# plt.xticks(x_ticks)
# plt.grid(True)
plt.legend()
plt.show()