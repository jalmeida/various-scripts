#!/bin/bash

HOST='avlsite001.example.com'
USERNAME='username'
PASSWORD='mypassword'
SRC_FOLDER1='/var/home/rancid/routers-ng/Latest/'
DST_FOLDER1='/usr/local/rancid/var/Legacy-NG/configs'
SRC_FOLDER2='/var/home/rancid/routers/Latest/'
DST_FOLDER2='/usr/local/rancid/var/Legacy-OLD/configs'

scp ${USERNAME}@${HOST}:${SRC_FOLDER1}* ${DST_FOLDER1}
scp ${USERNAME}@${HOST}:${SRC_FOLDER2}* ${DST_FOLDER2}
cd ${DST_FOLDER1}
cvs add *
cvs update
cvs commit -m Updated

cd ${DST_FOLDER2}
cvs add *
cvs update
cvs commit -m Updated
