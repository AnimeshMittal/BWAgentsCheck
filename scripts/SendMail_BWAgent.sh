#!/bin/sh
#
#
SCR_BIN=[[[ScriptHomeDirectory]]]
export Img1="$SCR_BIN/input/EmailTemplates/images/Image_1.png"
export Img2="$SCR_BIN/input/EmailTemplates/images/Image_2.png"
export Img3="$SCR_BIN/input/EmailTemplates/images/Image_3.png"
export Img4="$SCR_BIN/input/EmailTemplates/images/Image_4.png"

mail_boundary="$(uuidgen)/$(hostname)"
echo "To: $1
CC: $2
From: $3
Subject: $4
Content-Type: multipart/mixed; boundary=\"$mail_boundary\"
MIME-Version: 1.0

--$mail_boundary
Content-Type: text/html; charset="US-ASCII"
Content-Disposition: inline

$5

--$mail_boundary
Content-Type: image/png; name=$(basename $Img1)
Content-Disposition: inline; filename="$(basename $Img1)"
Content-Transfer-Encoding: base64
Content-ID: <image001.png>

`base64 $Img1`

--$mail_boundary
Content-Type: image/png; name=$(basename $Img2)
Content-Disposition: inline; filename="$(basename $Img2)"
Content-Transfer-Encoding: base64
Content-ID: <image002.png>

`base64 $Img2`

--$mail_boundary
Content-Type: image/png; name=$(basename $Img3)
Content-Disposition: inline; filename="$(basename $Img3)"
Content-Transfer-Encoding: base64
Content-ID: <image003.png>

`base64 $Img3`

--$mail_boundary
Content-Type: image/png; name=$(basename $Img4)
Content-Disposition: inline; filename="$(basename $Img4)"
Content-Transfer-Encoding: base64
Content-ID: <image004.png>

`base64 $Img4`

--$mail_boundary--" | /usr/sbin/sendmail -t
