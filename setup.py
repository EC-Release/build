#!/usr/bin/env python

__author__ = 'A. Yasuda <apolo.yasuda@ge.com>'

from distutils.core import setup

proxy = 'http://proxy-src.research.ge.com:8080'
os.environ['HTTPS_PROXY'] = proxy

setup(name='ec_dist',
      version='0.5.0',
      description='Enterprise-Connect Agent Distribution Setup',
      author='A. Yasuda',
      author_email='apolo.yasuda@ge.com',
      url='https://github.com/Enterprise-connect/sdk/wiki',
      packages=['ec_dist'],
      install_requires=['distutils','distutils.command']
     )
