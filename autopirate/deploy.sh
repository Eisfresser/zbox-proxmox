#!/bin/bash

# sync autopirate
scp autopirate/*.yml root@autopirate.local:/autopirate/
scp autopirate/homepage/services.yaml root@autopirate.local:/autopirate/config/homepage/services.yaml
scp autopirate/autopirate.sh root@autopirate.local:/autopirate/