
# coding: utf-8

# In[30]:

import re
import os
import subprocess


# In[32]:

testfile = open("timings.txt", "r")
file = testfile.read()

numbers = re.findall(r"[-+]?\d*\.\d+|\d+", file)

numbers = sorted(numbers, key=float, reverse=True)
for i in numbers:
    bashcall = "grep {} timings.txt".format(i)
    subprocess.call(bashcall, shell=True)
    


# 
