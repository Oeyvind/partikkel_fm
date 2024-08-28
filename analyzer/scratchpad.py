
import numpy as np
np.set_printoptions(suppress=True, precision=3)

g = [0.7,1.0,1.3]
d = [0.25, 0.5, 0.75]
x_parm = g
y_parm = d
x,y = np.meshgrid(x_parm, y_parm)
xx,yy = x.ravel(), y.ravel()

print(x_parm, "\n")
print(y_parm, "\n")
print(x, "\n")
print(y, "\n")
print(xx, "\n")
print(yy, "\n")

'''
g = [0.7,1.0,1.3]
d = [0.25, 0.5, 0.75]
m = [0.1, 0.2, 0.3]

count = 0
data = np.ndarray([len(g), len(d), len(m), 3])
for i in range(len(g)):
    for j in range(len(m)):
        for k in range(len(d)):
          data[i][j][k] = [i,j,k]
          #count += 1

print("all:\n", data)
#print("part:\n", data[:,:,0])
dly = 0.5
print("d={}:\n".format(dly), data[:,d.index(dly),:])

'''