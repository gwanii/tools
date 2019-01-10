#!/usr/bin/python
import subprocess as sp
import hashlib
import sys


cached = {}

def get_cache_images():
    err, output = sp.getstatusoutput("source ~/Oops/rc/newadminrc && glance image-list| awk '{print $2,$4}'|grep -")
    if not err:
        for rowImage in output.split('\n'):
            imageID, imageName = rowImage.split()
            cacheImageId = hashlib.sha1(bytes(imageID, 'utf-8')).hexdigest()
            cached[cacheImageId] = '%s %s' % (imageName, imageID)
    else:
        print('execute get_cache_images error')
        sys.exit(1)

def check_cache_images(host):
    print('- check cached images on host %s' % host)
    err, output = sp.getstatusoutput('ssh %s ls /var/lib/nova/instances/_base/' % host)
    if not err:
        for rowID in output.split('\n'):
            if rowID not in cached:
                print('  cache image not valid:', rowID)
    else:
        print('execute check_cache_images on %s error' % host)
        sys.exit(1)



def main():
    get_cache_images()
    check_cache_images('cp-1')
    check_cache_images('cp-2')


if __name__ == '__main__':
    main()