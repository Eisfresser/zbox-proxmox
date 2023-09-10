#!/bin/bash

# sync autopirate
scp autopirate/*.yml root@autopirate.local:/autopirate/
scp autopirate/homepage/*.yaml root@autopirate.local:/autopirate/config/homepage/
scp autopirate/autopirate.sh root@autopirate.local:/autopirate/
