__author__ = 'A. Yasuda <apolo.yasuda@ge.com>'

import urllib2, zipfile, os,time, fileinput, logging, hashlib
import subprocess as sp

class Common(object):
    def __init__(self,className):
        self.initLogger(className)
        
    def Exec(self,cmd):
        ref=sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE,shell=True)
        stdout, stderr=ref.communicate()    

        if ref.returncode!=0:
            raise RuntimeError("{} failed\n status code:\n {} stdout:\n {} stderr {}".format(cmd, ref.returncode, stdout, stderr))

        print(stdout)

    def Download(self,url):

        for x in range(0, 3):
            u = urllib2.urlopen(url)
            meta = u.info()
            file_name = url.split('/')[-1]                
            f = open(file_name, 'wb')
            try:
                file_size = int(meta.getheaders("Content-Length")[0])
                print("Downloading: {} Bytes: {}".format(file_name, file_size))
                file_size_dl = 0
                block_sz = 4096
                while True:
                    buffer = u.read(block_sz)

                    if not buffer:
                        break

                    file_size_dl += len(buffer)
                    f.write(buffer)
                    status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
                    status = status + chr(8)*(len(status)+1)
                    print(status),

                return f.close()
            
            except:
                print('error downloading file. retry again.')
                
            f.close()
        
            
    def Unzip(self,src,dst):
        with zipfile.ZipFile(src, 'r') as zip_ref:
            zip_ref.extractall(dst)
            zip_ref.close()

    def find(self, name, path):
        for root, dirs, files in os.walk(path):
            if name in files or name in dirs:
                print(os.path.join(root, name))
                return os.path.join(root, name)

        raise NameError('no file/directory found.')
    
    def sed(self, _file,text,repl):
        sfile=fileinput.input(files=(_file), inplace=True, backup='.bak')
        for line in sfile:
            print(line.replace(text, repl)),

        sfile.close()

    def initLogger(self,name):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)
        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)
        self.logger.addHandler(ch)
        formatter = logging.Formatter('%(asctime)s|%(name)s|%(levelname)s: %(message)s')
        ch.setFormatter(formatter)

    def checksum(self,fname):
        hash_md5 = hashlib.sha256()
        with open(fname, "rb") as f:

            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)

        return hash_md5.hexdigest()

    def chksumgen(self,_pth,_cfi):
        file = open('{}/{}'.format(_pth,_cfi),'w')
        for filename in os.listdir(_pth):
            if filename==_cfi:
                continue
            
            #print(filename)
            op = self.checksum('{}/{}'.format(_pth,filename))
            file.write(filename+": "+op+' (sha256) \n') 
            print(filename+': '+op)
        file.close()
        
