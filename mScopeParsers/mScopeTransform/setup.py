
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages


with open('README.md') as f:
    readme = f.read()

with open('LICENSE') as f:
    license = f.read()

pckgs = ['transform']
install = ['pyparsing', 'python-dateutil']

setup(
    name='mScopeTransformer',
    version='0.1dev',
    description='Data transformation into millianalyst schema',
    long_description=readme,
    author='Joshua Kimball',
    author_email='jmkimball@gatech.edu',
    url='https://github.gatech.edu/jkimball7/NewElba',
    license=license,
    packages=pckgs,
    install_requires=install
)
