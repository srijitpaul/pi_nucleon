
# coding: utf-8

# In[15]:

import numpy as np
import datetime


# In[22]:

#Default Parameters for source location generation
L    = 24
T    = 48
nsrc =  8
seed = 132
print('#[source_locations] {:%Y-%b-%d %H:%M:%S}'.format(datetime.datetime.now()))
print('#[source_locations] using seed = {}'.format(seed))
print('#[source_locations] using L = {}'.format(L))
print('#[source_locations] using T = {}'.format(T))
print('#[source_locations] using number of source locations = {}'.format(nsrc))


# In[2]:

config_data = np.loadtxt("config.list")


# In[12]:

config_number = config_data
#config_stream = config_data[:,1]
#config_name   = config_data[:,2]


# In[68]:

for index,num in enumerate(config_number):
    for i_src in range(0, 8):
        print("{:04d}".format(int(config_number[index])), 
 #         "\t{:06d}".format(int(config_stream[index])),
 #         "\t{:06d}".format(int(config_name[index])),
              "\t{:02d}".format(np.random.randint(0, 24)),
              "\t{:02d}".format(np.random.randint(0, 24)),
              "\t{:02d}".format(np.random.randint(0, 24)),
              "\t{:02d}".format(np.random.randint(0, 48)))
    

