import numpy as np
import matplotlib.pyplot as plt
D = 5.67e-15
Q = 1e15
t = 1800
L =2*np.sqrt(D*t)
pi = 3.14
x = np.arange(-10,10,0.1)
y = (Q/(L*np.sqrt(pi)))*np.exp(-(x**2/L**2))
plt.plot(x,y)
plt.show