import os 

file1 = "/etc/tor/torrc" 
file2 = "/path_to_your/torrc"
find = "ExitNodes"

user_input = input("Enter exit node country code: ")
i = find + " {" + user_input + "}\n"

with open(file2) as r:
    a = r.read()

with open(file1, "w") as f_r:
    f_r.write(a + i + "\n")
