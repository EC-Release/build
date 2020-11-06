__author__ = 'Apolo Yasuda <apolo.yasuda@ge.com>'

'''
   EC SDK build script
'''

import  os, json, base64, sys, threading, subprocess
from time import sleep

#import ec_common
from common import Common

c=Common(__name__)

PLUGINS=os.environ["PLUGINS"]
DIST=os.environ["DIST"]
BINARY="{}/{}/{}/{}".format(DIST,DIST,os.environ["ARTIFACT"],os.environ["ARTIFACT"])
#deprecated
#APIBIN="{}/{}".format(os.environ["API"],os.environ["API"])

#deprecated
#APISRC="{}/src/{}".format(os.environ["GOPATH"],os.environ["APIPKG"])
TLSSRC="{}/src/{}".format(os.environ["GOPATH"],os.environ["TLSPLUGINPKG"])
VLNSRC="{}/src/{}".format(os.environ["GOPATH"],os.environ["VLNPLUGINPKG"])

#deprecate kepware
#KEPSRC="{}/src/{}".format(os.environ["GOPATH"],os.environ["KEPPLUGINPKG"])
DHOME="{}/src/{}".format(os.environ["GOPATH"],os.environ["DHOME"])
TLSPLUGINBIN="{}/{}/{}/bin/{}".format(DIST,PLUGINS,os.environ["TLSPLUGIN"],os.environ["TLSPLUGIN"])
VLNPLUGINBIN="{}/{}/{}/bin/{}".format(DIST,PLUGINS,os.environ["VLNPLUGIN"],os.environ["VLNPLUGIN"])

#deprecated
#KEPPLUGINBIN="{}/{}/{}".format(PLUGINS,os.environ["KEPPLUGIN"],os.environ["KEPPLUGIN"])
EC_TAG=""

def test_cipher():
   agt="/{}_linux_sys".format(BINARY)
   
   print "cipher functional test"
   os.system("EC_PPS={} {} -hsh".format(os.environ["CA_PPRS"],BINARY))
             
def main():

    print "generate linux_amd64 artifacts with race; dns resolved by system"
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -tags netgo -v -o /{}_linux_sys {}/*.go".format(BINARY,DHOME))
    
    print "generate linux_amd64 artifacts with race; dns resolved by go"
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=go GOARCH=amd64 go build -tags netgo -v -o /{}_linux_var {}/*.go".format(BINARY,DHOME))

    #print "generate linux_adm64 secuity api binary"
    #os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -tags netgo -a -v -o /{}_linux {}/*.go".format(APIBIN, APISRC))

    os.system("/{}_linux_sys -inf".format(BINARY))
    #get the current rev
    op = subprocess.check_output(["/{}_linux_sys".format(BINARY), "-ver"])
    #EC_TAG =  op[op.rfind(" [")+2:op.rfind("]")]
    #fix missing brackets issue when parsing rev
    EC_TAG = op[op.rfind(" "):]
    TLSLDFLAGS="-X \"main.REV={}.tls\"".format(EC_TAG)
    VLNLDFLAGS="-X \"main.REV={}.vln\"".format(EC_TAG)
    #KEPLDFLAGS="-X main.REV={}.kep".format(EC_TAG)
    print "EC_TAG: {}".format(EC_TAG)

    #set EC_REV
    s = open('build_tag','w')
    print >>s,EC_TAG
    
    print "generate linux_amd64 plugins bin dns resolved by system"
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_linux_sys {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_linux_sys {}/*.go".format(VLNLDFLAGS,VLNPLUGINBIN,VLNSRC))
    #os.system('CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_linux_sys {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))

    print "generate linux_amd64 plugins dns resolved by go."
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=go GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_linux_var {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    os.system("CGO_ENABLED=1 GOOS=linux GODEBUG=netdns=go GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_linux_var {}/*.go".format(VLNLDFLAGS,VLNPLUGINBIN,VLNSRC))
    #os.system('CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=go GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_linux_var {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))


    print "generate darwin_amd64 artifacts"
    os.system("CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=cgo GOARCH=amd64 go build -tags netgo -a -v -o /{}_darwin_sys {}/*.go".format(BINARY,DHOME))
    os.system("CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=go GOARCH=amd64 go build -tags netgo -a -v -o /{}_darwin_var {}/*.go".format(BINARY,DHOME))

    print "generate darwin_amd64 plugins bin dns resolved by system"
    os.system("CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_darwin_sys {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    #os.system('CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_darwin_sys {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))

    print "generate darwin_amd64 plugins dns resolved by go."
    os.system("CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=go GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_darwin_var {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    #os.system('CGO_ENABLED=0 GOOS=darwin GODEBUG=netdns=go GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_darwin_var {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))


    print "generate windows_amd64 artifacts"
    os.system("CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=cgo GOARCH=amd64 go build -tags netgo -a -v -o /{}_windows_sys.exe {}/*.go".format(BINARY,DHOME))
    os.system("CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=go GOARCH=amd64 go build -tags netgo -a -v -o /{}_windows_var.exe {}/*.go".format(BINARY,DHOME))

    print "generate windows_amd64 plugins bin dns resolved by system"
    os.system("CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_windows_sys.exe {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    #os.system('CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=cgo GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_windows_sys.exe {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))

    print "generate windows_amd64 plugins dns resolved by go."
    os.system("CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=go GOARCH=amd64 go build -ldflags '{}' -tags netgo -a -v -o /{}_windows_var.exe {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    #os.system('CGO_ENABLED=0 GOOS=windows GODEBUG=netdns=go GOARCH=amd64 go build -ldflags "{}" -tags netgo -a -v -o /{}_windows_var.exe {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))

    
    print "generate linux_arm artifacts"
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=arm go build -tags netgo -a -v -o /{}_arm_sys {}/*.go".format(BINARY,DHOME))
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=go GOARCH=arm go build -tags netgo -a -v -o /{}_arm_var {}/*.go".format(BINARY,DHOME))

    print "generate linux_arm plugins bin dns resolved by system"
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=arm go build -ldflags '{}' -tags netgo -a -v -o /{}_arm_sys {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=arm go build -ldflags '{}' -tags netgo -a -v -o /{}_arm_sys {}/*.go".format(VLNLDFLAGS,VLNPLUGINBIN,VLNSRC))
    #os.system('CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=arm go build -ldflags "{}" -tags netgo -a -v -o /{}_arm_sys {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))

    print "generate linux_arm plugins dns resolved by go."
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=go GOARCH=arm go build -ldflags '{}' -tags netgo -a -v -o /{}_arm_var {}/*.go".format(TLSLDFLAGS,TLSPLUGINBIN,TLSSRC))
    os.system("CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=go GOARCH=arm go build -ldflags '{}' -tags netgo -a -v -o /{}_arm_var {}/*.go".format(VLNLDFLAGS,VLNPLUGINBIN,VLNSRC))
    #os.system('CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=go GOARCH=arm go build -ldflags "{}" -tags netgo -a -v -o /{}_arm_var {}/*.go'.format(KEPLDFLAGS,KEPPLUGINBIN,KEPSRC))


    print "copying plugins.yml examples.."
    os.system("cp {}/plugins.yml /{}/{}/{}/bin/".format(TLSSRC,DIST,PLUGINS,os.environ["TLSPLUGIN"]))
    os.system("cp {}/plugins.yml /{}/{}/{}/bin/".format(VLNSRC,DIST,PLUGINS,os.environ["VLNPLUGIN"]))
    #os.system("cp {}/plugins.yml /{}/{}".format(KEPSRC,PLUGINS,os.environ["KEPPLUGIN"]))

    
    CKF = 'checksum.txt'
    
    c.chksumgen('/{}/{}/{}'.format(DIST,DIST,os.environ["ARTIFACT"]),CKF)

    #temp remove lib
    #c.chksumgen('/{}'.format(LIB),CKF)

    op = subprocess.check_output(["ls", "-al", "/{}/{}/{}".format(DIST,DIST,os.environ["ARTIFACT"])])
    print op

    op = subprocess.check_output(["/{}_linux_sys".format(BINARY), "-ver"])
    print op
    
    fl = os.listdir('/{}/{}/{}'.format(DIST,DIST,os.environ["ARTIFACT"]))
    for filename in fl:
        if filename==CKF:
            continue
        
        os.system('cd /{}/{}/{}; tar -czvf {}.tar.gz ./{}'.format(DIST,DIST,os.environ["ARTIFACT"],filename,filename))
        os.system('rm /{}/{}/{}/{}'.format(DIST,DIST,os.environ["ARTIFACT"],filename))
    
    return
        
if __name__=='__main__':
    main()
