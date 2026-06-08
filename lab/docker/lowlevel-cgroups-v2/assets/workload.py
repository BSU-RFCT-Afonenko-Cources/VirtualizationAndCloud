#!/usr/bin/env python3
import ctypes, errno, os, signal, sys, time

def name(value):
    ctypes.CDLL(None).prctl(15, value.encode()[:15], 0, 0, 0)

def cpu():
    name(sys.argv[2]); x = 1
    while True: x = (x * 1103515245 + 12345) & 0x7fffffff

def memory():
    name(sys.argv[2]); time.sleep(.25); target = int(sys.argv[3]); chunks=[]
    try:
        while sum(map(len,chunks)) < target:
            block=bytearray(1024*1024); block[::4096]=b'x'*(len(block)//4096); chunks.append(block); time.sleep(.03)
        time.sleep(30)
    except MemoryError:
        sys.exit(42)

def forks():
    name(sys.argv[2]); time.sleep(.25); children=[]
    try:
        for _ in range(int(sys.argv[3])):
            try:
                pid=os.fork()
            except OSError as e:
                if e.errno in (errno.EAGAIN, errno.ENOMEM): break
                raise
            if pid == 0:
                name('cg-fork-child'); time.sleep(30); os._exit(0)
            children.append(pid)
        print(len(children), flush=True); time.sleep(1)
    finally:
        for pid in children:
            try: os.kill(pid, signal.SIGTERM)
            except ProcessLookupError: pass
        for pid in children:
            try: os.waitpid(pid, 0)
            except ChildProcessError: pass

def counter():
    name(sys.argv[2]); path=sys.argv[3]; value=0
    while True:
        value += 1
        tmp=path+'.tmp'; open(tmp,'w').write(str(value)+'\n'); os.replace(tmp,path); time.sleep(.1)

def writer():
    name(sys.argv[2]); time.sleep(.25); path=sys.argv[3]; total=int(sys.argv[4]); block=b'c'*(1024*1024)
    with open(path,'wb',buffering=0) as f:
        for _ in range(total): f.write(block)
        os.fsync(f.fileno())

mode=sys.argv[1]
{'cpu':cpu,'memory':memory,'forks':forks,'counter':counter,'writer':writer}[mode]()
