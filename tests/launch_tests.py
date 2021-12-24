import subprocess

a = subprocess.run(["pwd"], capture_output=True)
print(a)
print('hello world')
