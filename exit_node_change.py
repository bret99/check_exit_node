import os 

file1 = "/etc/tor/torrc" 
file2 = "torrc"

user_input = input("Enter exit node country code: ")
i = "ExitNodes {" + user_input + "}\n"

with open(file2) as r:
    a = r.read()

with open(file1, "w") as f_r:
    f_r.write(a + i + "\n")

