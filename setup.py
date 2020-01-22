#!/usr/bin/env python

__author__ = 'Chia Chang <chia.chang@ge.com>'

from distutils.core import setup

proxy = 'http://proxy-src.research.ge.com:8080'
os.environ['HTTPS_PROXY'] = proxy

setup(name='ec_dist',
      version='0.5.0',
      description='Enterprise-Connect Agent Distribution Setup',
      author='Chia Chang',
      author_email='chia.chang@ge.com',
      url='https://github.com/Enterprise-connect/ec-sdk/wiki',
      packages=['ec_dist'],
      install_requires=['distutils','distutils.command']
     )
