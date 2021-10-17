import os

file1 = "/etc/tor/torrc"
file2 = "~/torrc"
find = "ExitNodes"

user_input = input("\033[1;94m\nEnter exit node country code: \033[1;00m")
i = find + " {" + user_input + "}\n"

with open(file2) as r:
    a = r.read()

with open(file1, "w") as f_r:
    f_r.write(a + i + "\n")

os.system(
    'service tor restart && sleep 1.5 && ~/checkIP.sh')
